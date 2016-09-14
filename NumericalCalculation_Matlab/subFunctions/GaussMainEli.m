function x=GaussMainEli(A,b)
% Gauss列主元消去法 Gauss main element elimination method
% 列主元消法相当于对(A | b)先进行一系列行交换后对 再应用高斯消去法。
% A     Ax=b中的系数矩阵
% b     Ax=b中的非奇次项
% x     Ax=b中的未知变量的解
[n,m]=size(A);
if m~=n || m ~=length(b)
   error(message('请确保系数矩阵A为n阶方阵，且列向量b的元素个数为n！')) 
end
det=1; %存储行列式值
x=zeros(n,1);
for k=1:n-1
    amax=0; %选主元
    for i=k:n
        if abs(A(i,k))>amax
            amax=abs(A(i,k));
            r=i;
        end
    end
    if amax<1e-10
        return;
    end
    if r>k  %交换两行
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
    for i=k+1:n   %进行消元
        m=A(i,k)/A(k,k);
        for j=k+1:n
            A(i,j)=A(i,j)-m*A(k,j);
        end
        b(i)=b(i)-m*b(k);
    end
    det=det*A(k,k);
end
% det=det*a(n,n); 这一句在提供的代码里是有的，但是实际上没有起到作用。
for k=n:-1:1  %回代求解
    for j=k+1:n
        b(k)=b(k)-A(k,j)*x(j);
    end
    x(k)=b(k)/A(k,k);
end
