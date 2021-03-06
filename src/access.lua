local url = require "net.url"

-- local balancer_execute = require("kong.core.balancer").execute


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
  local hostHeader = buildHostHeader(conf.host)
  local ba = ngx.ctx.balancer_address
  if conf.host then
    ba.host = conf.host
  end
  if conf.port then
    ba.port = conf.port
  end
--  local ok, err = balancer_execute(ba)
--  if not ok then
--      ngx.log(ngx.WARN,"Can't change uptream: "..tostring(err))
--  end
  
  if ba.host then
    if ba.port then
      ngx.var.upstream_host = ba.host..":"..ba.port
     end
  end
  
  if ba.ip then
    ngx.log(ngx.WARN, "ip: "..ba.ip)
  end 
  
  if ba.port then
    ngx.log(ngx.WARN, "port: "..ba.port)
  end
  
  if ba.hostname then
    ngx.log(ngx.WARN, "hostname: "..ba.hostname)
  end
 
  ngx.log(ngx.WARN, "ngx.var.upstream_host: "..ngx.var.upstream_host)
  
end

return _M
