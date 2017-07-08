function sAddr = getMAC

ni = java.net.NetworkInterface.getNetworkInterfaces;
macStrs = {};
while ni.hasMoreElements
    macAddr = ni.nextElement.getHardwareAddress;
    if ~isempty(macAddr)
        macAddrStr = ['.' sprintf('%02X',mod(int16(macAddr),256))];
        macStrs{end+1} = macAddrStr; %#ok
    end
end
macStrs = sort(unique(macStrs));
sid = [macStrs{:}];