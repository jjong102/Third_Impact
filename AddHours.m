clc; clear;

% --- 1) 현재 날짜/시간 입력 ---
dateStr = input('현재 날짜와 시간 입력 (예: 2024-04-19 15): ', 's');

fmts = { ...
    'yyyy-MM-dd HH', ...
    'yyyy/MM/dd HH', ...
    'yyyy.MM.dd HH', ...
    'yyyy년 M월 d일 H시', ...
    'yyyy-MM-dd HH:mm', ...
    'yyyy/MM/dd HH:mm', ...
    'yyyy.MM.dd HH:mm' ...
    };

dt = [];
for k = 1:numel(fmts)
    try
        dt = datetime(dateStr, 'InputFormat', fmts{k});
        break;
    catch
    end
end
if isempty(dt)
    error('형식이 올바르지 않습니다.');
end
asda

% --- 2) 더할 시간(시간 단위) 입력 ---
deltaHours = input('더할 시간(시간 단위, 예: 50): ');