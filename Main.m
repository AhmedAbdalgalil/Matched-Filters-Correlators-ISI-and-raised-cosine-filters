clc; close all;
Length_of_wave=10;
A=1;
p=[5 4 3 2 1]/sqrt(55);
input_data =randi([0 1],1,Length_of_wave);
Tx = ((2*input_data)-1)*A;
Tx_Sampeled=upsample(Tx,5);
signal = conv(p,Tx_Sampeled);
p_matched = fliplr(p);
rect=[1 1 1 1 1]/sqrt(5);
%Requirement 1:
%a)Draw the output of both filters (in (e) above) on two subplots in the same 
%figure using two different colors, assuming a noise free system. Compare 
%between the outputs of the filters at the sampling instants.
p_matched_output=conv(p_matched,signal);
rect_output=conv(rect,signal);
figure();
subplot(2,1,1);
stem(p_matched_output,'g','.');
title(' matched filter output')
subplot(2,1,2); 
stem(rect_output,'r','.')
title(' rect filter output')
% the output of the matched filter and the output of a correlator to p[n] on 
%the same plot with two different colors.
%Signal_MIxed=signal*signal;
figure();
subplot(2,1,1);
stem(p_matched_output,'g','.');
title(' matched filter output')
subplot(2,1,2); 
for i = 1:5:50
 x(i:i+4)=signal(i:i+4).*p;
end
x=x(1:50);
t=intdump(x,5);
stem(t,'b');title('Correlatora + Int and Dump')
%2- Noise analysis:_

%a- Repeat a, b, and c from 1 above but generate 10000 bits instead of 10 bits
Length_of_wave=10000;
input_data =randi([0 1],1,Length_of_wave);
Tx = ((2*input_data)-1)*A;
Tx_Sampeled=upsample(Tx,5);
signal = conv(p,Tx_Sampeled);
N0=1;Eb=1;
X=randn(1,length(signal));
Noize=X*sqrt(N0/2);
V_n=Noize+signal;
The_receiver_array_capasty=10000;
The_receiver_array_matched = ones(1,The_receiver_array_capasty);
The_receiver_array_rect = ones(1,The_receiver_array_capasty);
The_receivered_bits_rect=ones(1,The_receiver_array_capasty);
The_receivered_bits_matched=ones(1,The_receiver_array_capasty);
BER_matched_Array=ones(1,8);
BER_theoretical=ones(1,8);
BER_rect_Array=ones(1,8);
for Eb_over_N0 =-2:5
    N0  =variance(Eb,Eb_over_N0);
    Noize=X*sqrt(N0/2);
    V_n=Noize+signal;
    V_n_matchedfiltered=conv(p_matched,V_n);
    
    V_n_RECfiltered=conv(rect,V_n);

    conter=1;
    %sampling
    for i=5:5:50000
        The_receiver_array_matched(conter)=V_n_matchedfiltered(i);
        The_receiver_array_rect(conter)=V_n_RECfiltered(i);
        conter=conter+1;
    end
    
   for i=1:10000
       if(The_receiver_array_matched(i)>0)
        The_receivered_bits_matched(i)=1;
       else
          The_receivered_bits_matched(i)=0;
       end
       if(The_receiver_array_rect(i)>0)
        The_receivered_bits_rect(i)=1;
       else
          The_receivered_bits_rect(i)=0;
       end
   end
   %%%%
   Error_num_matched=0;
   Error_num_rect=0; 
  for i=1:10000
       if(The_receivered_bits_matched(i)~=input_data(i))
       Error_num_matched=Error_num_matched+1;
       end
       if(The_receivered_bits_rect(i)~=input_data(i))
       Error_num_rect=Error_num_rect+1;
       end
   end
   BER_rec=Error_num_rect/The_receiver_array_capasty;
   BER_matched=Error_num_matched/The_receiver_array_capasty;
   BER_matched_Array(Eb_over_N0+3)=BER_matched;
   BER_rect_Array(Eb_over_N0+3)=BER_rec;
   
   BER_theoretical(Eb_over_N0+3)=0.5 *erfc(sqrt(Eb/N0));

   
end
%polting the results
figure();
semilogy(-2:5,BER_matched_Array);
hold all
semilogy(-2:5,BER_theoretical,'r');
grid on
title('BER matched ')
ylabel('BER')
xlabel('E_b/N_0 in db')
legend(' BER for matched Filter',' BER for theoritical');
figure();
semilogy(-2:5,BER_rect_Array)
hold all
semilogy(-2:5,BER_theoretical)
grid on
ylabel('BER')
xlabel('E_b/N_0 in dB')
title('BER rec')
legend(' BER for rec Filter',' BER for theoritical');

%3- ISI and raised cosine 
cases=[[0 2]
       [0 8]
       [1 2]
       [1 16]];
%%figure();
for i= 1:4
    Filter =rcosine(1,5,'sqrt',cases(i,1),cases(i,2));
    Length_of_wave=100;
    A=1;
    input_data =randi([0 1],1,Length_of_wave);
    Tx = ((2*input_data)-1)*A;
    Tx_Sampeled=upsample(Tx,5);
    transmited=conv(Tx_Sampeled,Filter);
    received=conv(Tx_Sampeled,Filter);
    %subplot(4,2,2*i-1);
    eyediagram(transmited,5);
    
    title("transmited siganl when rolloff= "+cases(i,1)+"delay= "+cases(i,2));
    
    %subplot(4,2,2*i);
    eyediagram(received,5)
        title("received siganl when rolloff= "+cases(i,1)+"delay= "+cases(i,2));
end

%variance
function N0  =variance(Eb,Eb_over_N0)
N0=Eb/(10^(Eb_over_N0/10));
end

