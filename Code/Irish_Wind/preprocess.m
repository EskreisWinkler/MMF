IWD = csvread('irish_wind_nh.csv');

%%%%%%%%%% IWD %%%%%%%%%%

%%%%% COL 1: YEAR
%%%%% COL 2: MONTH
%%%%% COL 3: DAY
%%%%% COL 4: RPT
%%%%% COL 5: VAL
%%%%% COL 6: ROS
%%%%% COL 7: KIL
%%%%% COL 8: SHA
%%%%% COL 9: BIR
%%%%% COL 10: DUB
%%%%% COL 11: CLA
%%%%% COL 12: MUL
%%%%% COL 13: CLO
%%%%% COL 14: BEL
%%%%% COL 15: MAL

IW_LOC = csvread('wind_loc.csv');

%%%%% ORDER OF COLUMNS IS:
%%%%    1       Valentia  VAL C
%%%%    2      Belmullet  BEL C
%%%%    3    Claremorris  CLA N
%%%%    4        Shannon  SHA C
%%%%    5  Roche's Point  RPT C
%%%%    6           Birr  BIR N
%%%%    7      Mullingar  MUL N
%%%%    8     Malin Head  MAL C
%%%%    9       Kilkenny  KIL N
%%%%    10        Clones  CLO N
%%%%    11        Dublin  DUB C
%%%%    12       Roslare  ROS C

size(IWD)
station_id = [5 1 12 9 4 6 11 3 7 10 2 8];
is_coast =   [1 1 1  0 1 0 1  0 0 0  1 1];
%%% MAKE MONTHLY WIND DATASET: We want first four columns to be 
%%% STATID/YEAR/MONTH/MONTH_IND/LONG/LAT/ISCOAST and then the average wind
%%% measurement at the site

IWD_m = zeros(size(IW_LOC,1)*length(unique(IWD(:,1)))*length(unique(IWD(:,2))),8);
YEARS = unique(IWD(:,1));
for cur_station = 1:size(IW_LOC,1)
    for cur_year = 1:length(unique(IWD(:,1)))
        for cur_month = 1:length(unique(IWD(:,2)))
            cur_id = (cur_station-1)*length(unique(IWD(:,1)))*length(unique(IWD(:,2)))...
                + (cur_year-1)*length(unique(IWD(:,2)))+cur_month;
            mean_wind = mean(IWD((IWD(:,1)==YEARS(cur_year))&(IWD(:,2)==cur_month)...
                ,3+cur_station));
            month_ID = (cur_year-1)*length(unique(IWD(:,2)))+cur_month;
            IWD_m(cur_id,:) = [station_id(cur_station) cur_year cur_month month_ID...
                IW_LOC(station_id(cur_station),1:2) is_coast(cur_station) mean_wind]; 
        end
    end
end

% FIRST TRY EXCLUDING MULINGAR FROM TEST DATA;
TRAIN_DATA = IWD_m(IWD_m(:,1)~=7,2:end);
TEST_DATA  = IWD_m(IWD_m(:,1)==7,2:end);
global TRAIN_DATA;
global TEST_DATA;

save('wind_data.mat','TRAIN_DATA','TEST_DATA')


figure(2)
hold on
for cur_stat = 1:11
plot(IWD_m(1:216,4),IWD_m(((cur_stat-1)*216+1):cur_stat*216,end))
end

plot(TEST_DATA(:,3),TEST_DATA(:,end),'LineWidth',4)
hold off
legend('Valentia','Belmullet','Claremorris','Shannon','Roches Point',...
    'Birr', 'Malin Head','Kilkenny','Clones','Dublin','Roslare','Mullingar')
m = zeros(size(IWD_m(1:216,4)));
for cur_stat = 1:11
    m = m+IWD_m(((cur_stat-1)*216+1):cur_stat*216,end);
end
m = m/11;

figure(3)
hold on
plot(IWD_m(1:216,4),m, 'LineWidth',2)
xlabel('MonthID')
ylabel('Wind Speed')
plot(TEST_DATA(:,3),TEST_DATA(:,end),'LineWidth',2)
hold off
legend('Avg of Others', 'True Speed')