function [LHS] = computeFemMdMatrix(xnodes, nconn,h,alpha,t)
ne = size(nconn,1);   % number of elements
nen = size(nconn,2);  % number of nodes per element
nn  = size(xnodes,1); % total number of nodes
nq  = 4;              % number of element integration points
ndim = 2;             % number of spatial dimensions (2 for 2D)

uK=@(x,y,t)2*cos(pi*t/8)*(-sin(pi*x)^2*sin(pi*y)*cos(pi*y));
vK=@(x,y,t)2*cos(pi*t/8)*(sin(pi*y)^2*sin(pi*x)*cos(pi*x));

LHS = sparse(nn,nn);
% Loop over elements
for ielt = 1:ne
    % Element matrices
    LHSe = zeros(nen,nen);
    % Coordinates for element nodes
    coords = xnodes(nconn(ielt,:)',:);
    
    [xq, wq, N, dNdx] = computeQuad2dFemShapeFunctions(coords); 
    u=0*(xq(:,1)); v=0*(xq(:,2));
    for iq = 1:nq
        u(iq)=uK(xq(iq,1),xq(iq,2),t);
        v(iq)=vK(xq(iq,1),xq(iq,2),t);
    end
    U=[u v];
    % Form element matrix using gauss quadrature
    for iq = 1:nq
        % Loop over node pairs
        for i = 1:nen
            for j = 1:nen
                for idim = 1:ndim
                       LHSe(i,j) =  LHSe(i,j)+...       
                        (h*alpha/(2*norm([U(nq,1) U(nq,2)])))*wq(iq)...
                        *(U(nq,idim))*dNdx(iq,i,idim)*N(iq,j);
                end
            end
        end    
    end
    
    % Assemble to global matrix
    for i = 1:nen
        I = nconn(ielt,i);
        for j = 1:nen
            J = nconn(ielt,j);
            LHS(I,J) = LHS(I,J) + LHSe(i,j);
        end
    end
    
end
