port = 80
OSS = 1 -- oversampling setting (0-3)
SDA_PIN = 6 -- sda pin, GPIO2
SCL_PIN = 1 -- scl pin, GPIO15

print("Sendtemp script initialized")

function sendData()
bmp180 = require("bmp180")
bmp180.init(SDA_PIN, SCL_PIN)
bmp180.read(OSS)
t = bmp180.getTemperature()
p = bmp180.getPressure()

-- temperature in degrees Celsius  and Farenheit
print("Temperature: "..(t/10).."."..(t%10).." deg C")
print("Temperature: "..(9 * t / 50 + 32).."."..(9 * t / 5 % 10).." deg F")
t1 = ""..(t/10).."."..(t%10)..""
p1 = ""..(p / 100).."."..(p % 100)..""
-- pressure in differents units
print("Pressure: "..(p).." Pa")
print("Pressure: "..(p / 100).."."..(p % 100).." hPa")
print("Pressure: "..(p / 100).."."..(p % 100).." mbar")
print("Pressure: "..(p * 75 / 10000).."."..((p * 75 % 10000) / 1000).." mmHg")


print("Sending data to database")
conn=net.createConnection(net.TCP, 0) 
conn:on("receive", function(conn, payload) print(payload) end)

conn:connect(80,'@SERVERIP') 
conn:send("GET /mcu.php?temp="..t1.."&pres="..p1.." HTTP/1.1\r\n") 
conn:send("Host: @FQDN\r\n") 
conn:send("Accept: */*\r\n") 
conn:send("User-Agent: Mozilla/4.0 (compatible; esp8266 Lua; Windows NT 5.1)\r\n")
conn:send("\r\n")
conn:on("sent",function(conn)
                      print("Closing connection")
                      conn:close()
                  end)
conn:on("disconnection", function(conn)
          print("Got disconnection...")
  end)
end

sendData()

-- send data every X ms
tmr.alarm(0, 180000, 1, function() sendData() end )
-- release module
bmp180 = nil
package.loaded["bmp180"]=nil
