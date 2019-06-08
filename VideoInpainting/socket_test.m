tcpipClient = tcpip('localhost',12112,'NetworkRole','Client');

fopen(tcpipClient);

data = '128 agaga';
fwrite(tcpipClient, data, 'char');

disp('ok')

while ~tcpipClient.BytesAvailable
    disp(tcpipClient.BytesAvailable);
end
data = fread(tcpipClient,tcpipClient.BytesAvailable, 'char')

   