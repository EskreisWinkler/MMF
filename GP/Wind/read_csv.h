int count_rows(string address) {
    int r = 0;
    ifstream infile(address);
    string line = "";
    while (getline(infile, line)){
        r++;
    }
    return r;
}


int count_cols(string address) {
    int c = 0;
    ifstream infile(address);
    string line = "";
    getline(infile, line);
    string word;
    stringstream strstr(line);
    
    while (getline(strstr,word, ',')){
        c ++;
    }
    return c;
}

MatrixXd read_csv(string address) {
    int r = count_rows(address);
    int c = count_cols(address);
    int cur_r,cur_c;
    cur_r = -1;
    cur_c = 0;
    float number;
    MatrixXd m(r,c);
    //cout << "Number of rows is "<< r << "\n";
    //cout << "Number of cols is "<< c << "\n";
    
    ifstream infile(address);
    string line = "";
    while (getline(infile, line)){
        stringstream strstr(line);
        string word;
        cur_r++;
        cur_c=0;
        while (getline(strstr,word,',')) {
            number = stof(word);
            m(cur_r,cur_c) = number;
            cur_c++;
        }
        
    }
    
    return m;
}
