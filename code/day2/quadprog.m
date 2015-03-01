function [X,fval,exitflag,output,lambda]=quadprog(H,f,A,B,Aeq,Beq,lb,ub,X0,options)
%QUADPROG Quadratic programming. 
%   X=QUADPROG(H,f,A,b) solves the quadratic programming problem:
%
%            min 0.5*x'*H*x + f'*x   subject to:  A*x <= b 
%             x    
%
%   X=QUADPROG(H,f,A,b,Aeq,beq) solves the problem above while additionally
%   satisfying the equality constraints Aeq*x = beq.
%
%   X=QUADPROG(H,f,A,b,Aeq,beq,LB,UB) defines a set of lower and upper
%   bounds on the design variables, X, so that the solution is in the 
%   range LB <= X <= UB. Use empty matrices for LB and UB
%   if no bounds exist. Set LB(i) = -Inf if X(i) is unbounded below; 
%   set UB(i) = Inf if X(i) is unbounded above.
%
%   X=QUADPROG(H,f,A,b,Aeq,beq,LB,UB,X0) sets the starting point to X0.
%
%   X=QUADPROG(H,f,A,b,Aeq,beq,LB,UB,X0,OPTIONS) minimizes with the default 
%   optimization parameters replaced by values in the structure OPTIONS, an 
%   argument created with the OPTIMSET function.  See OPTIMSET for details.  
%   Used options are Display, Diagnostics, TolX, TolFun, LargeScale, MaxIter, 
%   PrecondBandWidth, TypicalX, TolPCG, and MaxPCGIter. Currently, only
%   'final' and 'off' are valid values for the parameter Display ('iter'
%   is not available).
%
%   [X,FVAL]=QUADPROG(H,f,A,b) returns the value of the objective function at X:
%   FVAL = 0.5*X'*H*X + f'*X.
%
%   [X,FVAL,EXITFLAG] = QUADPROG(H,f,A,b) returns a string EXITFLAG that 
%   describes the exit condition of QUADPROG.  
%   If EXITFLAG is:
%      > 0 then QUADPROG converged with a solution X.
%      0   then the maximum number of iterations was exceeded (only occurs
%           with large-scale method).
%      < 0 then the problem is unbounded, infeasible, or 
%           QUADPROG failed to converge with a solution X.  
%
%   [X,FVAL,EXITFLAG,OUTPUT] = QUADPROG(H,f,A,b) returns a structure
%   OUTPUT with the number of iterations taken in OUTPUT.iterations,
%   the type of algorithm used in OUTPUT.algorithm, the number of conjugate
%   gradient iterations (if used) in OUTPUT.cgiterations, and a measure of
%   first order optimality (if used) in OUPUT.firstorderopt.
%
%   [X,FVAL,EXITFLAG,OUTPUT,LAMBDA]=QUADPROG(H,f,A,b) returns the set of 
%   Lagrangian multipliers LAMBDA, at the solution: LAMBDA.ineqlin for the 
%   linear inequalities A, LAMBDA.eqlin for the linear equalities Aeq, 
%   LAMBDA.lower for LB, and LAMBDA.upper for UB.

%   Copyright (c) 1990-98 by The MathWorks, Inc.
%   $Revision: 1.16 $  $Date: 1998/10/22 20:11:14 $
%   Andy Grace 7-9-90. Mary Ann Branch 9-30-96.

% Handle missing arguments

% New 9/1-2001 GSL
global XIT; 
global IT

defaultopt = optimset('display','final','Diagnostics','off',...
   'TolX',100*eps,'TolFun',100*eps,...
   'LargeScale','on','maxiter',200,...
   'PrecondBandWidth',0,'typicalx','ones(numberOfVariables,1)',...
   'TolPCG',0.1,'MaxPCGIter','numberOfVariables');

% If just 'defaults' passed in, return the default options in X
if nargin==1 & nargout <= 1 & isequal(H,'defaults')
   X = defaultopt;
   return
end

if nargin < 2, 
   error('QUADPROG requires at least two input arguments')
end

if nargin < 10, options =[];
   if nargin < 9, X0 = []; 
      if nargin < 8, ub = []; 
         if nargin < 7, lb = []; 
            if nargin < 6, Beq = []; 
               if nargin < 5, Aeq = [];
                  if nargin < 4, A = [];
                     if nargin < 3, B = [];
                     end, end, end, end, end, end, end, end

% Set up constant strings
medium =  'medium-scale: active-set';
large = 'large-scale';

if nargout > 4
   computeLambda = 1;
else 
   computeLambda = 0;
end

% Options setup
options = optimset(defaultopt,options);
largescale = isequal(optimget(options,'largescale'),'on');
diagnostics = isequal(optimget(options,'diagnostics','off'),'on');
switch optimget(options,'display')
case {'off', 'none'}
   verbosity = 0;
case 'iter'
   verbosity = 2;
case 'final'
   verbosity = 1;
case 'testing'
   verbosity = Inf;
otherwise
   verbosity = 1;
end

% Set the constraints up: defaults and check size
[nineqcstr,numberOfVariables]=size(A);
[neqcstr,numberOfVariableseq]=size(Aeq);
if isa(H,'double')
   lengthH = 0;
else 
   lengthH = length(H);
end
numberOfVariables = max([length(f),lengthH,numberOfVariables]); % In case A is empty
ncstr = nineqcstr + neqcstr;

if isempty(A), A=zeros(0,numberOfVariables); end
if isempty(B), B=zeros(0,1); end
if isempty(Aeq), Aeq=zeros(0,numberOfVariables); end
if isempty(Beq), Beq=zeros(0,1); end

% Expect vectors
f=f(:);
B=B(:);
Beq=Beq(:);

[X0,lb,ub,msg] = checkbounds(X0,lb,ub,numberOfVariables);
if ~isempty(msg)
   exitflag = -1;
   output = []; X=X0; fval = []; lambda = [];
   if verbosity > 0
      disp(msg)
   end
   return
end

% Check out H
if isa(H,'double')
   if  norm(H,'inf')==0 | isempty(H)
      H=[]; 
      % Really a lp problem
      caller = 'linprog1';
      warning('Hessian is empty or all zero; calling LINPROG');
      [X,fval,exitflag,output,lambda]=linprog1(f,A,B,Aeq,Beq,lb,ub,X0,options);
      return
   else
      caller = 'quadprog1';
      % Make sure it is symmetric
      if norm(H-H',inf) > eps
         if verbosity > -1
            warning('Your Hessian is not symmetric.  Resetting H=(H+H'')/2')
         end
         H = (H+H')*0.5;
      end
   end
end

% Use large-scale algorithm or not?
%    If any inequalities, 
%    or both equalities and bounds, 
%    or more equalities than variables,
%    or no equalities and no bounds and no inequalities
%    or asked for active set (~largescale) then call qpsub
if ( (nineqcstr > 0) | ...
      ( neqcstr > 0 & (sum(~isinf(ub))>0 | sum(~isinf(lb)) > 0)) | ...
      (neqcstr > numberOfVariables) | ...
      (neqcstr==0 & nineqcstr==0 & all(eq(ub, inf)) & all(eq(lb, -inf))) | ...  % unconstrained
      ~largescale)
   % (has linear inequalites  OR both equalities and bounds) OR 
   % ~largescale, then call active set code
   if largescale  & ( issparse(H) | issparse(A) | issparse(Aeq) )% asked for sparse
      if verbosity > 0
         warnstr = sprintf('%s\n%s\n', ...
            'This problem formulation not yet available for sparse matrices.',...
            'Converting to full to solve.');
         warning(warnstr);
      end
   end
   if ~isa(H,'double')
      error('H must be specified explicitly for medium-scale algorithm');
   end
   output.algorithm = medium;
else % call sqpmin when just bounds or just equalities
   output.algorithm = large;
end

if diagnostics 
   % Do diagnostics on information so far
   gradflag = []; hessflag = []; line_search=[];
   constflag = 0; gradconstflag = 0; non_eq=0;non_ineq=0;
   lin_eq=size(Aeq,1); lin_ineq=size(A,1); XOUT=ones(numberOfVariables,1);
   funfcn{1} = [];ff=[]; GRAD=[];HESS=[];
   confcn{1}=[];c=[];ceq=[];cGRAD=[];ceqGRAD=[];
   msg = diagnose('quadprog',output,gradflag,hessflag,constflag,gradconstflag,...
      line_search,options,XOUT,non_eq,...
      non_ineq,lin_eq,lin_ineq,lb,ub,funfcn,confcn,ff,GRAD,HESS,c,ceq,cGRAD,ceqGRAD);
end

% if any inequalities, or both equalities and bounds, or more equalities than bounds,
%    or asked for active set (~largescale) then call qpsub
if isequal(output.algorithm, medium)
   if isempty(X0), 
      X0=zeros(numberOfVariables,1); 
   end
   [X,lambdaqp,exitflag,output]= ...
      qpsub1(full(H),f,[full(Aeq);full(A)],[Beq;B],lb,ub,X0,neqcstr,verbosity,caller,ncstr,numberOfVariables,options); 
   output.algorithm = medium;
   
   XIT(IT,1)=X(1); XIT(IT,2)=X(2);  % New 9/1-2001 GSL

   
elseif isequal(output.algorithm,large)  % largescale: call sqpmin when just bounds or just equalities
   [X,fval,output,exitflag,lambda]=...
      sqpmin1(f,sparse(H),X0,sparse(Aeq),Beq,lb,ub,verbosity,options,computeLambda);
   
   if exitflag == -2  % Problem not handled by sqpmin at this time
      if largescale  & ( issparse(H) | issparse(A) | issparse(Aeq) )% asked for sparse
         warnstr = sprintf('%s\n%s\n', ...
            'This problem formulation not yet available for sparse matrices.',...
            'Converting to full to solve.');
         warning(warnstr);
      end
      
      if isempty(X0), 
         X0=zeros(numberOfVariables,1); 
      end
      
      [X,lambdaqp,exitflag,output]= ...
         qpsub1(full(H),f,[full(Aeq);full(A)],[Beq;B],lb,ub,X0,neqcstr,verbosity,caller,ncstr,numberOfVariables);
      output.algorithm = medium;
   end
end


if isequal(output.algorithm , medium)
   fval = 0.5*X'*(H*X)+f'*X; 
   llb = length(lb); 
   lub = length(ub);
   lambda.lower = zeros(llb,1);
   lambda.upper = zeros(lub,1);
   arglb = ~isinf(lb); lenarglb = nnz(arglb);
   argub = ~isinf(ub); lenargub = nnz(argub);
   lambda.eqlin = lambdaqp(1:neqcstr,1);
   lambda.ineqlin = lambdaqp(neqcstr+1:neqcstr+nineqcstr,1);
   lambda.lower(arglb) = lambdaqp(neqcstr+nineqcstr+1:neqcstr+nineqcstr+lenarglb);
   lambda.upper(argub) = lambdaqp(neqcstr+nineqcstr+lenarglb+1:neqcstr+nineqcstr+lenarglb+lenargub);
   
   output.firstorderopt=[];
   output.cgiterations =[];
   
   if verbosity > 0
      if ( exitflag ==1 )
         disp('Optimization terminated successfully.');   
      end
      if ( exitflag == 2)
         % do some sort of check here to see how unreliable
         disp('Optimization completed.'); 
      end
      if (exitflag ==0)
         disp('Maximum number of iterations exceeded;')
         disp('   increase options.MaxIter')
      end
      
   end
end



