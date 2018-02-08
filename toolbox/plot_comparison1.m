%%
%Data
no_dist = [];
no_dist.color1_mean = -0.011595;
no_dist.color1_std = 0.413701;
no_dist.color1_std_range  = [-0.017803,+0.019400];
no_dist.color2_mean = 0.025211;
no_dist.color2_std = 0.792516;
no_dist.color2_std_range  = [-0.042112,+0.046876];
no_dist.depth_mean = 0.018127;
no_dist.depth_std = 1.504885;
no_dist.depth_std_range  = [-0.002335,+0.002342] ;

woffset = [];
woffset.color1_mean = -0.002333;
woffset.color1_std = 0.324316;
woffset.color1_std_range  = [-0.013956,+0.015208];
woffset.color2_mean = 0.019293;
woffset.color2_std = 0.721450;
woffset.color2_std_range  = [-0.038336,+0.042673];
woffset.depth_mean = 0.033979;
woffset.depth_std = 1.117654 ;
woffset.depth_std_range  = [-0.001734,+0.001739] ;

best = [];
best.color1_mean = -0.012670;
best.color1_std = 0.320585 ;
best.color1_std_range  = [-0.013796,+0.015033];
best.color2_mean = 0.062964;
best.color2_std = 0.829205 ;
best.color2_std_range  = [-0.044061,+0.049046];
best.depth_mean = 0.023446;
best.depth_std = 0.771058  ;
best.depth_std_range  = [-0.001196,+0.001200] ;

%%
figure(1);
clf;
[ax,h1,h2]=plotyy([0 1],[0 1],[0 1],[10 0]);
delete(h1)
delete(h2)

%Pixels
axes(ax(1));
ylim([0,1]);
xlim([0,3.5]);
hold on
errorbar(0.8,no_dist.color1_std,-no_dist.color1_std_range(1),no_dist.color1_std_range(2),'*','LineWidth',2);
errorbar(1.0,woffset.color1_std,-woffset.color1_std_range(1),woffset.color1_std_range(2));
errorbar(1.2,best.color1_std,-best.color1_std_range(1),best.color1_std_range(2));

errorbar(1.8,no_dist.color2_std,-no_dist.color2_std_range(1),no_dist.color2_std_range(2));
errorbar(2.0,woffset.color2_std,-woffset.color2_std_range(1),woffset.color2_std_range(2));
errorbar(2.2,best.color2_std,-best.color2_std_range(1),best.color2_std_range(2));

%Disparity
axes(ax(2));
ylim([0,2]);
xlim([0,3.5]);
hold on
errorbar(2.8,no_dist.depth_std,-no_dist.depth_std_range(1),no_dist.depth_std_range(2));
errorbar(3.0,woffset.depth_std,-woffset.depth_std_range(1),woffset.depth_std_range(2));
errorbar(3.2,best.depth_std,-best.depth_std_range(1),best.depth_std_range(2));