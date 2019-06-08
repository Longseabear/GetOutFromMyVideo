function res = refine()

tcpipClient = tcpip('localhost',1556,'NetworkRole','Client');

fopen(tcpipClient);

data = '128 agaga';
fwrite(tcpipClient, data, 'char');

disp('ok')

while ~tcpipClient.BytesAvailable
    
end
data = fread(tcpipClient,tcpipClient.BytesAvailable, 'char');
disp(data)
end

