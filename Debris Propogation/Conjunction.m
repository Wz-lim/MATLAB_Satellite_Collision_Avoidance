function windowNum = Conjunction(dMinTarget,satellite_1,satellite_2)         
    
    %Obtaining position data and associated time with aer function
    [~,~,range,tOut] = aer(satellite_1,satellite_2);

    kCloseIdx  = find(range<dMinTarget);
    dW         = [0 diff(kCloseIdx)];
    kWindow    = zeros(2,length(kCloseIdx));
    j          = 1;

    %Obtaining windows where satellites are within minimum target range
    for m = 1:length(dW)
      if dW(m)~=1
        % single point window
        kWindow(1,j) = max(1,kCloseIdx(m)-1);
        kWindow(2,j) = kCloseIdx(m)+1;
        j = j+1;
      elseif j>1
        % update window end as long as diff==1
        kWindow(2,j-1) = kCloseIdx(m)+1;
      end
    end
    
    kWindow = kWindow(:,1:j-1);
    windowNum = size(kWindow,2);
    
    %Datetime of windows where relative distance is less than target distance
    windows = tOut(kWindow);
    if size(windows,2)>=3
      disp(windows(:,1:3)')
    else
      disp(windows')
    end
end