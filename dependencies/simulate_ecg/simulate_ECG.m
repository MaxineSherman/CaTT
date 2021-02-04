function ECG = simulate_ECG(param,HR,noise,x)

%% fill in empty inputs
if nargin < 4; x     = 0:2:8000; end
if nargin < 3; noise = 0.3;      end
if nargin < 2; HR    = 70;       end

%% add noise to the wave parameters?
addnoise = true;

% param a is amplitude
% param d is duration
% param t is p-r interval
if nargin == 0 | isempty(param)
   
      param.pwav.a   = 0.25;  param.pwav.d   = 0.09;   param.pwav.t = 0.16;
      param.qwav.a   = 0.025; param.qwav.d   = 0.066;  param.qwav.t = 0.166;
      param.qrswav.a = 1.6;   param.qrswav.d = 0.11;
      param.swav.a   = 0.25;  param.swav.d   = 0.066;  param.swav.t = 0.09;
      param.twav.a   = 0.35;  param.twav.d   = 0.142;  param.twav.t = 0.3;
      param.uwav.a   = 0.035; param.uwav.d   = 0.0476; param.uwav.t = 0.433;
     
end

%% add values into parameter structure
param.x     = x;
param.noise = noise;
param.HR    = HR;
param.li    = 30/param.HR;
param.x     = param.x./1000;

%% add noise to the parameters?
if addnoise
    wavs = {'pwav','qwav','qrswav','swav','twav','uwav'};
    
    for i = 1:numel(wavs)
        eval(['f = fieldnames(param.' wavs{i} ');']);
        for j = 1:numel(f)
            eval(['val = param.' wavs{i} '.' f{j} ';']);
            eval(['param.' wavs{i} '.' f{j} ' = param.' wavs{i} '.' f{j} ' + normrnd(0,val/100);']);
        end
    end
end

%% get waves
pwav   = p_wav(param.x,param.pwav.a,param.pwav.d,param.pwav.t,param.li);
qwav   = q_wav(param.x,param.qwav.a,param.qwav.d,param.qwav.t,param.li);
qrswav = qrs_wav(param.x,param.qrswav.a,param.qrswav.d,param.li);
swav   = s_wav(param.x,param.swav.a,param.swav.d,param.swav.t,param.li);
twav   = t_wav(param.x,param.twav.a,param.twav.d,param.twav.t,param.li);
uwav   = u_wav(param.x,param.uwav.a,param.uwav.d,param.uwav.t,param.li);

%% get ECG
ECG    = pwav+qrswav+twav+swav+qwav+uwav+normrnd(0,param.noise,1,numel(param.x));