setwd("~/Google_Drive/15fall/Kondor/Code/Abalone")
data = read.csv('abalone.csv', sep=',', header=FALSE)

# NEED TO REPLACE THE GENDER VARIABLE IN COLUMN 1


g_f = 1*(data[,1]=='F');
g_i = 1*(data[,1]=='I');
g_m = 1*(data[,1]=='M');
new_data = data.frame(f=g_f,i=g_i,m=g_m, old_data = data[,2:dim(data)[2]])

write.table(new_data,file='abalone_nh.csv', sep=',',row.names = FALSE,col.names = FALSE)