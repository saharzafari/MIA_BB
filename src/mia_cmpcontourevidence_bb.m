function contourevidence = mia_cmpcontourevidence_bb(I,k,rmin,rmax,alpha,beta,gamma,vis)
% mia_contourevidence performs contourevidenc extraction step of the method.

%   Synopsis
%       contourevidence = contourevidence = mia_cmpcontourevidence_bb(I,k,rmin,rmax,alpha,beta,gamma,vis)
%   Description
%        Returns the contour evidences (visible parts of the objects ) 
%        to infernce the visible parts. It involves two separate tasks:
%        contour segmentation and segment grouping
%   Inputs 
%          - I           binary image
%          - k           kth adjucnet points to the corner point
%          - rmax        minum radial 
%          - rmin        maximum radial 
%          - aplha       weighing parameter for concavity
%          - beta        weighing parameter for elipcity
%          - gamma       weighing parameter for symmetry
%          - vis         0 or 1 for visualization puropose
%   Outputs
%         - contourevidence    a cell array contating the visile objects boundaries 
% 
%   Authors
%          Sahar Zafari <sahar.zafari(at)lut(dot)fi>
%
%   Changes
%       14/11/2016  First Edition
%----------------------------------------------------------------------------------------

    % parameters for css method
    [C,T_angle,sig,H,L,Endpoint,Gap_size] = parse_inputs();
    % extract the conecct component
    [L, nmcc] = bwlabeln(I,8);
    counter = 0; 
    % iterate over each connected component
     for  n = 1:nmcc
        fprintf('Processing coneccted component%2d :\n',n)
        lb = (L==n);
        bnd{n} = bwboundaries(lb);
        % concave point extraction
        fprintf('Extracting the concave points\n')
        [idxcp{n},xc{n},yc{n},bnd{n}]= mia_cmpconcavepoint_css(lb,bnd{n},C,T_angle,sig,H,L,Endpoint,Gap_size,k,vis);
        % segment the boundaries by the detetcted concave points
        fprintf('Segmenting the curve by detected concave points\n')
        segments{n} = mia_segmentcurve(bnd{n}',idxcp{n});
        fprintf('Detecting the seed points\n')
        segments{n} = mia_cmpseedpoints(segments{n},L,[rmin:rmax]);
        % combine the boundary segment of objects and boundary segment of hole inside the object 
        segments{n} = mia_cmbseg(segments{n});
       % segmnet grouping by branch and bound
        fprintf('Performing segment grouping by BB\n');
        Shat= mia_groupsegments_bb(segments{n},xc{n},yc{n},alpha,beta,gamma,I);
        % groupe the contour segments
        for jj= 1:length(Shat)
            counter =counter+1;
            contourevidence{counter} = mia_groupsegments(segments{n}(1,Shat{jj})); 
        end
        fprintf('..............................................\n')
     end
     if vis == 1
        figure(1),imshow(L); hold on
        title('Concave points, countor segments and detected seedpoints')
        mia_viscp(segments,xc,yc)
        pause (0.5)
        figure(2),imshow(L); hold on
        title('Contour Evidences')
        mia_visevidecnes(contourevidence)
        pause (0.5)
     end

