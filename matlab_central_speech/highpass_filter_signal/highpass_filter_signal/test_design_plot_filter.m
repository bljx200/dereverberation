% test_design_plot_filter
%
    fs=20000;
    ifilt=2;
    bwidth=100;
    tband=100;
    
    [b,n]=design_plot_filter(ifilt,bwidth,tband,fs);
    fprintf('n:%d, b(1):%6.2f \n',n,b(1));