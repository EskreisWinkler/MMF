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
%%% MAKE MONTHLY WIND DATASET: We want first XXX columns to be 
%%% STATID (1)/YEAR (2)/MONTH (3)/DAY (4)/DAY_IND (5) /LONG (6)/LAT (7) (no avg-ing by columns)
%%% last column in matrix is WINDSPEED (8)
n.vars = 8;
n.days = size(IWD,1);
n.stations= length(station_id);

IWD_new = zeros(n.days*n.stations,n.vars);

YEARS = unique(IWD(:,1));

for i = 1:n.stations
    cur_id = (i-1)*n.days+1;
    IWD_new(cur_id:(cur_id+n.days-1),:) = [repmat(station_id(i),n.days,1),IWD(:,1), ...
        IWD(:,2), IWD(:,3), (1:n.days)', repmat(IW_LOC(station_id(i),1),n.days,1),...
        repmat(IW_LOC(station_id(i),2),n.days,1), IWD(:,3+i)];
end

% normalize DATA (non-RESPONSE) parts of the data matrix
for col = 2:(size(IWD_new,2)-1)
   IWD_new(:,col) = (IWD_new(:,col) -  mean(IWD_new(:,col)));
   IWD_new(:,col) = IWD_new(:,col)/max(abs(IWD_new(:,col)));
end

% FIRST TRY EXCLUDING MULINGAR FROM TEST DATA;
TRAIN_DATA = IWD_new(IWD_new(:,1)~=7,1:end);
TEST_DATA  = IWD_new(IWD_new(:,1)==7,1:end);
%global TRAIN_DATA;
%global TEST_DATA;




save('full_wind_data.mat','TRAIN_DATA','TEST_DATA','n')


figure(2)
hold on
temp_ind = 5;
wind_ind = 8;
for i = 1:length(unique(TRAIN_DATA(:,1)))
    cur_id = (i-1)*n.days+1;
    inds = cur_id:(cur_id+n.days-1);
    plot(TRAIN_DATA(inds,temp_ind),TRAIN_DATA(inds,end),'LineWidth',0.5);
end

plot(TEST_DATA(:,temp_ind),TEST_DATA(:,end),'LineWidth',0.5)
hold off
legend('Valentia','Belmullet','Claremorris','Shannon','Roches Point',...
    'Birr', 'Malin Head','Kilkenny','Clones','Dublin','Roslare','Mullingar')
m = zeros(n.days,1);
for i = 1:(n.stations-1)
    cur_id = (i-1)*n.days+1;
    inds = cur_id:(cur_id+n.days-1);
    m = m+TRAIN_DATA(inds,end);
end
m = m/(n.stations-1);

figure(3)
hold on
plot(TRAIN_DATA(inds,temp_ind),m, 'LineWidth',1)
xlabel('DayID')
ylabel('Wind Speed')
plot(TEST_DATA(:,temp_ind),TEST_DATA(:,end),'LineWidth',1);
hold off
legend('Avg of Others', 'True Speed');

