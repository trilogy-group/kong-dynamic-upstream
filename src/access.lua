local url = require "net.url"

local balancer_execute = require("kong.core.balancer").execute


local _M = {}

local function buildHostHeader(newHost)
  local u = url.parse(newHost)
  local hostHeader = u.host
  if u.port then
    hostHeader = hostHeader .. ":" .. u.port
  end
  return hostHeader
end

local function replaceHost(url, newHost)
  local pathIndex = url:find('[^/]/[^/]')

  if not pathIndex then
    if newHost:find('[^/]/[^/]') == nil and newHost:sub(#newHost) ~= "/" then
      return newHost .. "/"
    end

    return newHost
  end

  if newHost:sub(#newHost) == "/" then
    newHost = newHost:sub(1, -2)
  end

  local path = url:sub(pathIndex + 1)
  return newHost .. path
end

function _M.execute(conf)
  local hostHeader = buildHostHeader(conf.replacement_url)
  local ba = ngx.ctx.balancer_address
  if conf.host then
    ba.host = conf.host
  end
  if conf.port then
    ba.port = conf.port
  end
  local ok, err = balancer_execute(ba)
  if not ok then
      ngx.log(ngx.ERROR,"Can`t change uptream: "..tostring(err))
  end
  ngx.var.upstream_host = ba.hostname..":"..ba.port

  ngx.log(ngx.DEBUG, "ip: "..ba.ip)
  ngx.log(ngx.DEBUG, "port: "..ba.port)
  ngx.log(ngx.DEBUG, "hostname: "..ba.hostname)
  ngx.log(ngx.DEBUG, "ngx.var.upstream_host: "..ngx.var.upstream_host)
end

return _M
