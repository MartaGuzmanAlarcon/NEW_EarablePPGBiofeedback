function data=conversion(m)

m(:,10)=m(:,10).*10^-3*(5.75/3.3);
m(:,11)=m(:,11).*10^-3*(5.75/3.3);
m(:,12)=m(:,12).*10^-3*(5.75/3.3);

%Cometa acquires in microV --> to convert in V
l=m(:,6).*10^-3;
% Cometa conversion: EMGVALUE : 3.3V= ACTUAL VALUE : 5V
l=l.*(5.75/3.3);

%Finapres conversion 
%scaling=10/300;
scaling=0.033333333;
l=(l+5)./scaling;
m(:,6)=l;


m(:,6)=[m(8000:end,6); zeros(8000-1,1)];

%CO 
m(:,8)=m(:,8).*10^-3;
m(:,8)=m(:,8).*(5.75/3.3);
scaling=0.2;
m(:,8)=(m(:,8)+5)./scaling;

m(:,8)=[m(8000:end,8); zeros(8000-1,1)];

%SV 
m(:,7)=m(:,7).*10^-3;
m(:,7)=m(:,7).*(5.75/3.3);
scaling=0.05;
m(:,7)=(m(:,7)+5)./scaling;

m(:,7)=[m(8000:end,7); zeros(8000-1,1)];

%ZAO

% m(:,9)=m(:,9).*10^-3;
% m(:,9)=m(:,9).*(5.75/3.3);
% scaling=10;
% m(:,9)=(m(:,9)+5)./scaling;
% 
% m(:,9)=[m(8000:end,9); zeros(8000-1,1)];

% PW
m(:,9)=m(:,9).*10^-3;
m(:,9)=m(:,9).*(5.75/3.3);


%fiAP
m(:,5)=m(:,5).*10^-3;
m(:,5)=m(:,5).*(5.75/3.3);
scaling=0.025;
m(:,5)=(m(:,5)+5)./scaling;

m(:,8)=[m(8000:end,8); zeros(8000-1,1)];


m(:,3)=m(:,3).*10^-3;
m(:,3)=m(:,3).*(5.75/3.3);
%scaling=1.25;
%m(:,3)=(m(:,3)+5)./scaling;


data=m;
end
