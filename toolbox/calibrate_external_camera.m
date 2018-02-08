function [Rrel,trel,Ra,ta]=calibrate_external_camera(Xw,Ka,kca,Pa,Kb,kcb,Pb)
  image_count = length(Xw);
  assert(length(Pa)==image_count);
  assert(length(Pb)==image_count);
  
  %Initial calibration
  Ha = cell(1,image_count);
  Hb = cell(1,image_count);
  Ra0 = cell(1,image_count);
  ta0 = cell(1,image_count);
  Rb0 = cell(1,image_count);
  tb0 = cell(1,image_count);
  for i=1:image_count
    count = size(Xw{i},2);

    [~,ta0{i},Ra0{i}] = compute_extrinsic_init(Pa{i},[Xw{1};zeros(1,size(Xw{1},2))],[Ka(1,1),Ka(2,2)],[Ka(1,3),Ka(2,3)],kca,0);
%     Xw_mean = mean(Xw{i},2);
%     Xwn = Xw{i} - repmat(Xw_mean,1,count);
% 
%     Pn = normalize(Pa{i},Ka,kca);
%     
%     Ha{i} = homography_from_corners(Pn,Xwn);
%     sc = mean([norm(Ha{i}(:,1));norm(Ha{i}(:,2))]);
%     Ha{i} = Ha{i}/sc;
%     
%     [Ra0{i},ta0{i}] = extern_from_homography(eye(3),Ha{i});
%     ta0{i} = ta0{i}+[Xw_mean;0];
    [~,tb0{i},Rb0{i}] = compute_extrinsic_init(Pb{i},[Xw{1};zeros(1,size(Xw{1},2))],[Kb(1,1),Kb(2,2)],[Kb(1,3),Kb(2,3)],kcb,0);
  
  end
  Rrel0m = zeros(3,image_count);
  trel0m = zeros(3,image_count);
  for i=1:image_count
    Rrel0m(:,i) = rotationpars(Rb0{i}*Ra0{i}');
    trel0m(:,i) = tb0{i}-ta0{i};
  end
  Rrel0 = mean(Rrel0m,2);
  trel0 = mean(trel0m,2);
  
  %Refinement
  raw0=params2raw(Rrel0,trel0,Ra0,ta0);
  minimization_options=optimset('LargeScale','off','Algorithm','levenberg-marquardt','Display','iter', 'TolFun',1e-4,'TolX',1e-8,'MaxFunEvals',20000,'MaxIter',1000);
  [raw_final] = lsqnonlin(@(x) calibrate_external_camera_cost(x,Xw,Ka,kca,Pa,Kb,kcb,Pb),raw0,[],[],minimization_options);
  [Rrel,trel,Ra,ta] = raw2params(raw_final,image_count);
end

function raw=params2raw(Rrel,trel,Ra,ta)
  raw = [];
  raw = [raw, Rrel', trel'];
  image_count = length(Ra);
  for i=1:image_count
    raw = [raw, rotationpars(Ra{i})', ta{i}'];
  end
end

function [Rrel,trel,Ra,ta]=raw2params(raw,image_count)
  Rrel = rotationmat(raw(1:3));
  trel = raw(4:6)';
  base = 7;
  
  Ra = cell(1,image_count);
  ta = cell(1,image_count)';
  for i=1:image_count
    Ra{i} = rotationmat(raw(base:base+2));
    ta{i} = raw(base+3:base+5)';
    base = base+6;
  end
end

function cost=calibrate_external_camera_cost(raw,Xw,Ka,kca,Pa,Kb,kcb,Pb)
  image_count = length(Xw);
  
  [Rrel,trel,Ra,ta] = raw2params(raw,image_count);
  
  cost = [];
  for i=1:image_count
%     count = size(Xw{i},2);
    
    Paa = project_points_k(Xw{i},Ka,kca,Ra{i},ta{i});
    %Paa = Ka*(Ra{i}*Xw + repmat(ta{i},1,count));
    %Paa = Paa(1:2,:) ./ repmat(Paa(3,:),2,1);
    err = sum((Pa{i}-Paa).^2).^0.5;
    cost = [cost, err];

    Pbb = project_points_k(Xw{i},Kb,kcb,Rrel*Ra{i},trel+Rrel*ta{i});
    %Pbb = Kb*(Rrel*Ra{i}*Xa + repmat(trel+Rrel*ta{i},1,count));
    %Pbb = Pbb(1:2,:) ./ repmat(Pbb(3,:),2,1);
    err = sum((Pb{i}-Pbb).^2).^0.5;
    cost = [cost, err];
  end
end