local a=128;local b=162;local function c(d,e)local f=component and component.list(d)()if not f and e then error("missing component '"..d.."'")end;return f and component.proxy(f)or nil end;local g=c("drone",true)local h=c("navigation",true)local i=c("inventory_controller",false)local j=c("modem",false)local k=0xFFCC33;local l=0x66CC66;local m=0x6699FF;local n={}function handleMessage(o,p)if o=='Farming'then for q,r in ipairs(n)do if string.find(string.format(r.label),string.format(p))then n[q].time=os.time()end end end end;function sleep(s)local s=s or 0.05;if j==nil then computer.pullSignal(s)return nil end;local t,u,v,b,w,o,p=computer.pullSignal(s)if t=="modem_message"then handleMessage(o,p)end end;function calcMove(x,y)local z={}local A={}for u,B in ipairs(h.findWaypoints(a))do if string.find(B.label,x.label)then A=B end end;z[1]=A.position[1]+y[1]z[2]=A.position[2]+y[2]z[3]=A.position[3]+y[3]return z end;function moveTo(x,y)local z={}while true do z=calcMove(x,y)g.move(z[1],z[2],z[3])sleep(0.5)while g.getVelocity()>0.5 do sleep(0.2)end;z=calcMove(x,y)if z[1]==0 and z[2]==0 and z[3]==0 then break else g.move(math.random(-1,1),math.random(-1,1),math.random(-1,1))end;while g.getVelocity()>0.5 do sleep(0.2)end end end;function findClose(C)local D={}D.dist=math.huge;D.w=nil;for u,x in ipairs(h.findWaypoints(a))do if string.find(x.label,C)then local w=math.abs(x.position[1])+math.abs(x.position[2])+math.abs(x.position[3])if w<D.dist then D['dist']=w;D['w']=x end end end;if D.w then return D['w']else g.setStatusText(C.."\nnot found")end end;function energyCheck()if computer.energy()<computer.maxEnergy()*0.2 then g.setLightColor(k)local y={}y={0,1,0}moveTo(findClose('Charging'),y)while computer.energy()<computer.maxEnergy()*0.9 do sleep(1)end end end;function emptyInv()local E={0,1,0}g.setLightColor(m)g.setStatusText('Emptying\nStorage')moveTo(findClose('DropOff'),E)for A=1,4 do g.select(A)g.drop(0)end;g.select(1)end;function invCheck()if g.count(3)>0 then emptyInv()end end;function initFarms()local F=h.findWaypoints(a)for u,x in ipairs(F)do if string.find(x.label,'Farm')then x.time=os.time()+math.random(-5,5)table.insert(n,x)end end end;function initPlots(farm)local G={}for H=1,8 do G[H]={}end;G[1]={-4,1,4}G[2]={-4,1,1}G[3]={-4,1,-2}G[4]={-1,1,-2}G[5]={2,1,-2}G[6]={2,1,1}G[7]={2,1,4}G[8]={-1,1,4}if farm.redstone>0 then local I={}for H=1,8 do local J=nil;repeat J=math.random(8)until G[J]I[H]=G[J]end;G=I end;return G end;function farmPlot(farm,K,L)energyCheck()invCheck()g.setLightColor(l)g.setStatusText(farm.label..'\nPlot: '..L)moveTo(farm,K)local M=-1;local N=0;g.setAcceleration(0.45)for O=1,3 do g.use(0)for P=1,2 do g.move(0,0,M)while g.getOffset()>0.5 or g.getVelocity()>0.5 do sleep(0.05)end;g.use(0)end;M=M*-1;if N<2 then g.move(1,0,0)while g.getOffset()>0.5 or g.getVelocity()>0.5 do sleep(0.05)end;N=N+1 end end;g.setAcceleration(2)end;function farmField(farm)local Q=initPlots(farm)for q,r in ipairs(n)do if string.find(string.format(r.label),string.format(farm.label))then n[q].time=os.time()end end;j.broadcast(b,'Farming',farm.label)for L,K in pairs(Q)do farmPlot(farm,K,L)end end;function farm()local M=-1;local R={}while true do local S=math.huge;local farm={}for u,r in ipairs(n)do if r.time<S then S=r.time;farm=r end end;farmField(farm)end end;math.randomseed(os.time())math.random()math.random()math.random()j.open(b)energyCheck()invCheck()initFarms()farm()