function x=GaussMainEli(A,b)
% Gauss����Ԫ��ȥ�� Gauss main element elimination method
% ����Ԫ�����൱�ڶ�(A | b)�Ƚ���һϵ���н������ ��Ӧ�ø�˹��ȥ����
% A     Ax=b�е�ϵ������
% b     Ax=b�еķ������
% x     Ax=b�е�δ֪�����Ľ�
[n,m]=size(A);
if m~=n || m ~=length(b)
   error(message('��ȷ��ϵ������AΪn�׷�����������b��Ԫ�ظ���Ϊn��')) 
end
det=1; %�洢����ʽֵ
x=zeros(n,1);
for k=1:n-1
    amax=0; %ѡ��Ԫ
    for i=k:n
        if abs(A(i,k))>amax
            amax=abs(A(i,k));
            r=i;
        end
    end
    if amax<1e-10
        return;
    end
    if r>k  %��������
        for j=k:n
            z=A(k,j);
            A(k,j)=A(r,j);
            A(r,j)=z;
        end
        z=b(k);
        b(k)=b(r);
        b(r)=z;
        det=-det;
    end
    for i=k+1:n   %������Ԫ
        m=A(i,k)/A(k,k);
        for j=k+1:n
            A(i,j)=A(i,j)-m*A(k,j);
        end
        b(i)=b(i)-m*b(k);
    end
    det=det*A(k,k);
end
% det=det*a(n,n); ��һ�����ṩ�Ĵ��������еģ�����ʵ����û�������á�
for k=n:-1:1  %�ش����
    for j=k+1:n
        b(k)=b(k)-A(k,j)*x(j);
    end
    x(k)=b(k)/A(k,k);
end
