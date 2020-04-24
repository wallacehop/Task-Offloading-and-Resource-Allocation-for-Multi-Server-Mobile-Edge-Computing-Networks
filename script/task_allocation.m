function [max_objective, X, F] = task_allocation( ...
    userNumber,...              % �û�����
    serverNumber,...            % ����������
    sub_bandNumber,...          % �Ӵ�����
    T_min,...                   % �¶��½�
    alpha,...                   % �¶ȵ��½���
    k, ...                      % �����ռ�Ĵ�С
    para...                     % �������
)
%TA Task allocation,��������㷨������ģ���˻��㷨

    [x_old,fx_old,F] = genOriginX(userNumber, serverNumber,sub_bandNumber,para);    %�õ���ʼ��
    
    picture = zeros(2,1);
    iterations = 1;
    T = userNumber;
    max_objective = 0;
    
    while(T>T_min)
        for I=1:k
            x_new = getneighbourhood(x_old,userNumber, serverNumber,sub_bandNumber);
            [fx_new, F_new] = Fx(x_new,para);
            delta = fx_new-fx_old;
            if (delta>0)
                x_old = x_new;
                fx_old = fx_new;
                if fx_new > max_objective
                    max_objective = fx_new;
                    X = x_new;
                    F = F_new;
                end
            else
                pro=getProbability(delta,T);
                if(pro>rand)
                    x_old=x_new;
                    fx_old = fx_new;
                end
            end
        end
        picture(iterations,1) = T;
        picture(iterations,2) = fx_old;
        iterations = iterations + 1;
        T=T*alpha;
    end
%     figure
%     plot(picture(:,1),picture(:,2),'b-.');
%     set(gca,'XDir','reverse');      %��X����ת
%     title('��׼ģ���˻��㷨������������Ż�');
%     xlabel('�¶�T');
%     ylabel('Ŀ�꺯��ֵ');
end
 
function res = getneighbourhood(x,userNumber,serverNumber,sub_bandNumber)
    user = unidrnd(userNumber);     %ָ��Ҫ�Ŷ����û�����
    flag_found = 0;
    for server = 1:serverNumber
        for band = 1:sub_bandNumber
            if x(user,server,band) ~= 0
                flag_found = 1;
                break;  %�ҵ��û�������ķ�������Ƶ��
            end
        end
        if flag_found == 1
            break;
        end
    end
    %�����Ŷ���ʽ���������߸�ֵ
    chosen = rand;
    if chosen > 0.2
        if chosen < 0.75   %55%�ĸ��ʸ����û��ķ�������ѡ��offload��
            x(user,server,band) = 0;
            vary_server = unidrnd(serverNumber);    %Ŀ�������
            vary_band = randi(sub_bandNumber);    %Ŀ��Ƶ��
            x(user,vary_server,vary_band) = 1;
        else    %25%�ĸ��ʸ����û���Ƶ����ѡ��offload��
            if sub_bandNumber ~= 1
                x(user,server,band) = 0;
                vary_band = unidrnd(sub_bandNumber);    %Ŀ��Ƶ��
                while vary_band == band
                    vary_band = unidrnd(sub_bandNumber);
                end
                x(user,server,vary_band) = 1;
            end
        end
    else 
        if chosen > 0.05  %15%�ĸ��ʽ��������û��ķ�������Ƶ��
            if userNumber ~= 1
                user_other = unidrnd(userNumber);    %ָ����һ���û�
                while user_other == user
                    user_other = unidrnd(userNumber);
                end
                flag_found = 0;
                for server_other = 1:serverNumber
                    for band_other=1:sub_bandNumber
                        if x(user_other,server_other,band_other) ~= 0
                            flag_found = 1;
                            break;  %�ҵ���һ���û�������ķ�������Ƶ��
                        end
                    end
                    if flag_found == 1
                        break;
                    end
                end
                xValue =  x(user,server,band);
                xValue_other =  x(user_other,server_other,band_other);
                x(user,server,band) = 0;
                x(user_other,server_other,band_other) = 0;
                x(user,server_other,band_other) = xValue_other;  %����Ƶ���ͷ�����
                x(user_other,server,band) = xValue;
            end
        else    %5%�ĸ��ʸı���û��ľ���
            x(user,server,band) = 1 - x(user,server,band);
        end
    end
    res = x;
end
 
function p = getProbability(delta,t)
    p = exp(delta/t);
end

function [seed,old_J,F] = genOriginX(userNumber, serverNumber,sub_bandNumber,para)
%GenRandSeed    ��������Լ����������Ӿ���
    seed = zeros(userNumber, serverNumber,sub_bandNumber);
    old_J = 0;
    for user=1:userNumber
        find = 0;
        for server=1:serverNumber
            for band=1:sub_bandNumber
                seed(user,server,band) = 1;
                [new_J,new_F] = Fx(seed,para);
                if new_J > old_J
                    old_J = new_J;
                    F = new_F;
                    find = 1;
                    break;
                else
                    seed(user,server,band) = 0;
                end
            end
            if find == 1
                break;
            end
        end
    end
end