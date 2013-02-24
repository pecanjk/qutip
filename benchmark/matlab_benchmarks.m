function []=matlab_benchmarks()
%Create array to hold test results
test_results=zeros(1,16);


%test #1
%perform basic operator algebra to construct JC-Hamiltonian
clearvars -except test_results;
Nc=20;
wc = 1.0 * 2 * pi;   
wa = 1.0 * 2 * pi;
g  = 0.05 * 2 * pi;
tic;
a=tensor(destroy(Nc),identity(2));
%create spin-operators
sm=tensor(identity(Nc),sigmam());
%build Jaynes-Cummings Hamiltonian
H=wc * a' * a + wa * sm' * sm + g * (a' + a) * (sm + sm');
time=toc;
test_results(1,1)=time;
%----------------------------------------------------------


%test #2
%tensor 6 spin operators
clearvars -except test_results;
tic;
tensor(sigmax(),sigmay(),sigmaz(),sigmay(),sigmaz(),sigmax());
time=toc;
test_results(1,2)=time;
%----------------------------------------------------------


%test #3
%tensor 6 spin operators
clearvars -except test_results;
out=tensor(sigmax(),sigmay(),sigmaz(),sigmay(),sigmaz(),sigmax());
tic;
ptrace(out,[1,3,4]);
time=toc;
test_results(1,3)=time;
%----------------------------------------------------------


%test #4
%matrix exponentiation to construct squeezed state and coherent state
clearvars -except test_results;
N=20;
alpha=2+2i;
sp=1.25i;
tic;
a=destroy(N);
grnd=basis(N);
D_oper=expm(alpha*a'-conj(alpha)*a);
S_oper=expm((1/2.0)*conj(sp)*a^2-(1/2.0)*sp*(a')^2);
coh_state=D_oper*grnd;
sqz_state=S_oper*grnd;
time=toc;
test_results(1,4)=time;
%----------------------------------------------------------


%test #5
%cavity+qubit steady state
clearvars -except test_results;
N=10;kappa = 2; gamma = 0.2; g = 1;
wc = 0; w0 = 0; wl = 0; E = 0.5;
tic;
ida = identity(N); idatom = identity(2); 
a  = tensor(destroy(N),idatom);
sm = tensor(ida,sigmam);
H = (w0-wl)*sm'*sm + (wc-wl)*a'*a + i*g*(a'*sm - sm'*a) + E*(a'+a);
C1    = sqrt(2*kappa)*a;% Collapse operators
C2    = sqrt(gamma)*sm;
C1dC1 = C1'*C1;
C2dC2 = C2'*C2;
LH = -i * (spre(H) - spost(H)); % Calculate the Liouvillian
L1 = spre(C1)*spost(C1')-0.5*spre(C1dC1)-0.5*spost(C1dC1);
L2 = spre(C2)*spost(C2')-0.5*spre(C2dC2)-0.5*spost(C2dC2);
L  = LH+L1+L2;
rhoss = steady(L);% Find steady state
time=toc;
test_results(1,5)=time;
%----------------------------------------------------------


%test #6
%cavity+qubit master equation
clearvars -except test_results;
kappa = 2; gamma = 0.2; g = 1;
wc = 0; w0 = 0; wl = 0; E = 0.5;
N = 10;
tlist = linspace(0,10,200);
tic;
ida = identity(N); idatom = identity(2); 
a  = tensor(destroy(N),idatom);
sm = tensor(ida,sigmam);
H = (w0-wl)*sm'*sm + (wc-wl)*a'*a + i*g*(a'*sm - sm'*a) + E*(a'+a);
C1  = sqrt(2*kappa)*a;
C2  = sqrt(gamma)*sm;
C1dC1 = C1'*C1;
C2dC2 = C2'*C2;
LH = -i * (spre(H) - spost(H)); 
L1 = spre(C1)*spost(C1')-0.5*spre(C1dC1)-0.5*spost(C1dC1);
L2 = spre(C2)*spost(C2')-0.5*spre(C2dC2)-0.5*spost(C2dC2);
L = LH+L1+L2;
psi0 = tensor(basis(N,1),basis(2,2));
rho0 = psi0 * psi0';
ode2file('file1.dat',L,rho0,tlist);
odesolve('file1.dat','file2.dat');
fid = fopen('file2.dat','rb');
rho = qoread(fid,dims(rho0),size(tlist));
time=toc;
test_results(1,6)=time;
%----------------------------------------------------------


%test #7
%cavity+qubit monte carlo (compare with mcsolver)
clearvars -except test_results;
kappa = 2; gamma = 0.2; g = 1;
wc = 0; w0 = 0; wl = 0; E = 0.5;
N = 10;
ntraj = 500;
tlist = linspace(0,10,200);
tic;
ida = identity(N); idatom = identity(2); 
% Define cavity field and atomic operators
a  = tensor(destroy(N),idatom);
sm = tensor(ida,sigmam);
% Hamiltonian
H = (w0-wl)*sm'*sm + (wc-wl)*a'*a + i*g*(a'*sm - sm'*a) + E*(a'+a);
% Collapse operators
C1  = sqrt(2*kappa)*a;
C2  = sqrt(gamma)*sm;
C1dC1 = C1'*C1;
C2dC2 = C2'*C2;
% Calculate Heff
Heff = H - 0.5*i*(C1dC1+C2dC2);
% Initial state
psi0 = tensor(basis(N,1),basis(2,2));
% Quantum Monte Carlo simulation
nexpect = mc2file('test.dat',-i*Heff,{C1,C2},{C1dC1,C2dC2,a},psi0,tlist,ntraj);
mcsolve('test.dat','out.dat');
fid = fopen('out.dat','rb');
[iter,count1,count2,infield] = expread(fid,nexpect,tlist);
fclose(fid);
time=toc;
test_results(1,7)=time;
%----------------------------------------------------------


%test #8
%cavity+qubit monte carlo (compare with mcsolve_f90)
%just copy time from test #7
test_results(1,8)=time;
%----------------------------------------------------------


%test #9
%cavity+qubit Wigner function
clearvars -except test_results;
kappa = 2; gamma = 0.2; g = 1;
wc = 0; w0 = 0; wl = 0; E = 0.5;
N = 10;
tlist = linspace(0,10,200);
ida = identity(N); idatom = identity(2); 
a  = tensor(destroy(N),idatom);
sm = tensor(ida,sigmam);
H = (w0-wl)*sm'*sm + (wc-wl)*a'*a + i*g*(a'*sm - sm'*a) + E*(a'+a);
C1  = sqrt(2*kappa)*a;
C2  = sqrt(gamma)*sm;
C1dC1 = C1'*C1;
C2dC2 = C2'*C2;
LH = -i * (spre(H) - spost(H)); 
L1 = spre(C1)*spost(C1')-0.5*spre(C1dC1)-0.5*spost(C1dC1);
L2 = spre(C2)*spost(C2')-0.5*spre(C2dC2)-0.5*spost(C2dC2);
L = LH+L1+L2;
psi0 = tensor(basis(N,1),basis(2,2));
rho0 = psi0 * psi0';
ode2file('file1.dat',L,rho0,tlist);
odesolve('file1.dat','file2.dat');
fid = fopen('file2.dat','rb');
rho = qoread(fid,dims(rho0),200);
rho_cavity=ptrace(rho,1);
xvec=linspace(-10,10,200);
tic;
W=wfunc(rho,xvec,xvec);
time=toc;
test_results(1,9)=time;
%----------------------------------------------------------


%test #10
%spin chain with 4 spins (master equation)
clearvars -except test_results;
N = 4; %number of spins
h  = 1.0 * 2 * pi * ones(1,N); 
Jz = 0.1 * 2 * pi * ones(1,N);
Jx = 0.1 * 2 * pi * ones(1,N);
Jy = 0.1 * 2 * pi * ones(1,N);
gamma = 0.01 * ones(1,N);
psi_list={basis(2,2)};
for ii=2:N
    psi_list{ii}=basis(2,1);
end
psi0=tensor(psi_list{:});
rho0 = psi0 * psi0';
tlist = linspace(0, 10, 200);
si = identity(2);
sx = sigmax();
sy = sigmay();
sz = sigmaz();
sx_list = {};
sy_list = {};
sz_list = {};

for n=1:N
    op_list = {};
    for m=1:N
        op_list{m}=si;
    end
    op_list{n}=sx;
    sx_list{n}=tensor(op_list{:});
    op_list{n}=sy;
    sy_list{n}=tensor(op_list{:});
    op_list{n}=sz;
    sz_list{n}=tensor(op_list{:});
end
H=0;
for n=1:N
    H=H+h(n)+sz_list{n};
end
for n=1:N-1
    H=H- 0.5 * Jx(n) * sx_list{n} * sx_list{n+1};
    H=H- 0.5 * Jy(n) * sy_list{n} * sy_list{n+1};
    H=H- 0.5 * Jz(n) * sz_list{n} * sz_list{n+1};
end
tic;
LH=-1i * (spre(H) - spost(H));
LC=0;
for n=1:N
    C1=sqrt(gamma(n))*sz_list{n};
    C1dC1=C1'*C1;
    LC=LC+spre(C1)*spost(C1')-0.5*spre(C1dC1)-0.5*spost(C1dC1);
end
L=LH+LC;
options.mxstep = 2500;
tic;
ode2file('file1.dat',L,rho0,tlist,options);
odesolve('file1.dat','file2.dat');
time=toc;
test_results(1,10)=time;
%----------------------------------------------------------


%test #11
%spin chain with 4 spins (monte carlo)
clearvars -except test_results;
N = 4; %number of spins
h  = 1.0 * 2 * pi * ones(1,N); 
Jz = 0.1 * 2 * pi * ones(1,N);
Jx = 0.1 * 2 * pi * ones(1,N);
Jy = 0.1 * 2 * pi * ones(1,N);
gamma = 0.01 * ones(1,N);
psi_list={basis(2,2)};
for ii=2:N
    psi_list{ii}=basis(2,1);
end
psi0=tensor(psi_list{:});
tlist = linspace(0, 10, 200);
si = identity(2);
sx = sigmax();
sy = sigmay();
sz = sigmaz();
sx_list = {};
sy_list = {};
sz_list = {};

for n=1:N
    op_list = {};
    for m=1:N
        op_list{m}=si;
    end
    op_list{n}=sx;
    sx_list{n}=tensor(op_list{:});
    op_list{n}=sy;
    sy_list{n}=tensor(op_list{:});
    op_list{n}=sz;
    sz_list{n}=tensor(op_list{:});
end
H=0;
for n=1:N
    H=H+h(n)+sz_list{n};
end
for n=1:N-1
    H=H- 0.5 * Jx(n) * sx_list{n} * sx_list{n+1};
    H=H- 0.5 * Jy(n) * sy_list{n} * sy_list{n+1};
    H=H- 0.5 * Jz(n) * sz_list{n} * sz_list{n+1};
end
Heff=H;
c_op_list={};
tic;
for n=1:N
    C1=sqrt(gamma(n))*sz_list{n};
    c_op_list{n}=C1;
    C1dC1=C1'*C1;
    Heff=Heff-0.5i*C1dC1;
end
options.mxstep = 2500;
ntraj=500;
nexpect = mc2file('test.dat',-i*Heff,c_op_list,sz_list,psi0,tlist,ntraj,options);
mcsolve('test.dat','out.dat');
time=toc;
test_results(1,11)=time;
%----------------------------------------------------------


%test #12
%spin chain with 4 spins (monte carlo F90)
%just copy results from test 11
test_results(1,12)=time;
%----------------------------------------------------------


%test #13
%spin chain with 6 spins (master equation)
clearvars -except test_results;
N = 6; %number of spins
h  = 1.0 * 2 * pi * ones(1,N); 
Jz = 0.1 * 2 * pi * ones(1,N);
Jx = 0.1 * 2 * pi * ones(1,N);
Jy = 0.1 * 2 * pi * ones(1,N);
gamma = 0.01 * ones(1,N);
psi_list={basis(2,2)};
for ii=2:N
    psi_list{ii}=basis(2,1);
end
psi0=tensor(psi_list{:});
rho0 = psi0 * psi0';
tlist = linspace(0, 10, 200);
si = identity(2);
sx = sigmax();
sy = sigmay();
sz = sigmaz();
sx_list = {};
sy_list = {};
sz_list = {};

for n=1:N
    op_list = {};
    for m=1:N
        op_list{m}=si;
    end
    op_list{n}=sx;
    sx_list{n}=tensor(op_list{:});
    op_list{n}=sy;
    sy_list{n}=tensor(op_list{:});
    op_list{n}=sz;
    sz_list{n}=tensor(op_list{:});
end
H=0;
for n=1:N
    H=H+h(n)+sz_list{n};
end
for n=1:N-1
    H=H- 0.5 * Jx(n) * sx_list{n} * sx_list{n+1};
    H=H- 0.5 * Jy(n) * sy_list{n} * sy_list{n+1};
    H=H- 0.5 * Jz(n) * sz_list{n} * sz_list{n+1};
end
tic;
LH=-1i * (spre(H) - spost(H));
LC=0;
for n=1:N
    C1=sqrt(gamma(n))*sz_list{n};
    C1dC1=C1'*C1;
    LC=LC+spre(C1)*spost(C1')-0.5*spre(C1dC1)-0.5*spost(C1dC1);
end
L=LH+LC;
options.mxstep = 2500;
tic;
ode2file('file1.dat',L,rho0,tlist,options);
odesolve('file1.dat','file2.dat');
time=toc;
test_results(1,13)=time;
%----------------------------------------------------------



%test #14
%spin chain with 6 spins (monte carlo)
clearvars -except test_results;
N = 6; %number of spins
h  = 1.0 * 2 * pi * ones(1,N); 
Jz = 0.1 * 2 * pi * ones(1,N);
Jx = 0.1 * 2 * pi * ones(1,N);
Jy = 0.1 * 2 * pi * ones(1,N);
gamma = 0.01 * ones(1,N);
psi_list={basis(2,2)};
for ii=2:N
    psi_list{ii}=basis(2,1);
end
psi0=tensor(psi_list{:});
tlist = linspace(0, 10, 200);
si = identity(2);
sx = sigmax();
sy = sigmay();
sz = sigmaz();
sx_list = {};
sy_list = {};
sz_list = {};

for n=1:N
    op_list = {};
    for m=1:N
        op_list{m}=si;
    end
    op_list{n}=sx;
    sx_list{n}=tensor(op_list{:});
    op_list{n}=sy;
    sy_list{n}=tensor(op_list{:});
    op_list{n}=sz;
    sz_list{n}=tensor(op_list{:});
end
H=0;
for n=1:N
    H=H+h(n)+sz_list{n};
end
for n=1:N-1
    H=H- 0.5 * Jx(n) * sx_list{n} * sx_list{n+1};
    H=H- 0.5 * Jy(n) * sy_list{n} * sy_list{n+1};
    H=H- 0.5 * Jz(n) * sz_list{n} * sz_list{n+1};
end
Heff=H;
c_op_list={};
tic;
for n=1:N
    C1=sqrt(gamma(n))*sz_list{n};
    c_op_list{n}=C1;
    C1dC1=C1'*C1;
    Heff=Heff-0.5i*C1dC1;
end
options.mxstep = 2500;
ntraj=500;
nexpect = mc2file('test.dat',-i*Heff,c_op_list,sz_list,psi0,tlist,ntraj,options);
mcsolve('test.dat','out.dat');
time=toc;
test_results(1,14)=time;
%----------------------------------------------------------


%test #15
%spin chain with 6 spins (monte carlo F90 compare)
%just copy results from test 14
test_results(1,15)=time;
%----------------------------------------------------------


%test #16
%steadystate optomechanical system
clearvars -except test_results;
Nc=6;
Nm=45;
alpha=0.311;
g0=0.36;						
kappa=0.3;
gamma=0.00147;
delta=0.0;
idc=identity(Nc);
idm=identity(Nm);
a=tensor(destroy(Nc),idm);
b=tensor(idc,destroy(Nm));
cc=sqrt(kappa)*a;
cm=sqrt(gamma)*b;
ccdcc=cc'*cc;
cmdcm=cm'*cm;

H=(-delta+g0*(b'+b))*(a'+a)+(b'*b)+alpha*(a'+a);

LH=-1i * (spre(H) - spost(H));
LC=spre(cc)*spost(cc')-0.5*spre(ccdcc)-0.5*spost(ccdcc);
LM=spre(cm)*spost(cm')-0.5*spre(cmdcm)-0.5*spost(cmdcm);
L=LH+LC+LM;
tic;
rhoss = steady(L);% Find steady state
time=toc;
test_results(1,16)=time;
%----------------------------------------------------------






xlswrite('matlab_benchmarks',test_results);