function equalizer = equalization_filter(tab,impulse)
%EQUALIZATION_FILTER 이 함수의 요약 설명 위치
%   자세한 설명 위치
mid = floor(length(impulse)/2);
if tab ==3
    equalizer = [impulse(mid) impulse(mid-1) impulse(mid-2);
                impulse(mid+1) impulse(mid) impulse(mid-1);
                impulse(mid+2) impulse(mid+1) impulse(mid)];
elseif tab == 5
    equalizer = [impulse(mid-1) impulse(mid-2) 0;
                impulse(mid) impulse(mid-1) impulse(mid-2);
                impulse(mid+1) impulse(mid) impulse(mid-1);
                impulse(mid+2) impulse(mid+1) impulse(mid);
                0 impulse(mid+2) impulse(mid+1)];
elseif tab == 7
    equalizer = [impulse(mid-2) 0 0;
                impulse(mid-1) impulse(mid-2) 0;
                impulse(mid) impulse(mid-1) impulse(mid-2);
                impulse(mid+1) impulse(mid) impulse(mid-1);
                impulse(mid+2) impulse(mid+1) impulse(mid);
                0 impulse(mid+2) impulse(mid+1);
                0 0 impulse(mid+2)];
end
end

