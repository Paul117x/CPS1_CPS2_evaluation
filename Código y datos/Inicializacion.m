%Inicializacion.m
clc;
%%

%Lectura de datos.
fprintf('Seleccione el mes cuyos datos se cargar�n a simulink:\n');
fprintf('1 = Agosto, 2 = Diciembre, Cualquier otro valor');
fprintf(' para cancelar (no se eliminar�n datos de memoria ');
fprintf('si se cancela de esta manera).\n');
p(1,2) = input('Selecci�n: ');
clc;
if p(1,2) == 1
    clear; p(1,2) = 1;
    auxd = xlsread('demanda_agosto.xlsx','demanda_agosto','D2:D745');
    auxg = xlsread('generacion_agosto.xlsx',...
        'generacion_agosto','C2:C1489');
elseif p(1,2) == 2
    clear; p(1,2) = 2;
    auxd = xlsread('demanda_diciembre.xlsx','demanda_diciembre',...
            'D2:D745');
        auxg = xlsread('generacion_diciembre.xlsx',...
            'generacion_diciembre','C2:C1489');
else
    error('Selecci�n no v�lida, intente de nuevo.');
end
%%
%Acomodo de informaci�n en matrices.
%La generaci�n renovable se acomoda en una misma columna para cada d�a,
%por lo que se requieren 48 (24 + 24) renglones en cada columna.
%Tras cada iteraci�n se separan las generaciones renovables a sus
%respectivos vectores, quedando de magnitud 744 x 1, siendo esto el mes
%completo.
aux = zeros(48,31);
for n = 1:31
    if n == 1
        aux(1:48,1) = auxg(1:48);
        b(1+24*(n-1):24+24*(n-1)) = aux(1:24,n);
        c(1+24*(n-1):24+24*(n-1)) = aux(25:48,n);
    else
        aux(1:48,n) = auxg(48*(n-1)+1:(96+48*(n-2)));
        b(1+24*(n-1):24+24*(n-1)) = aux(1:24,n);
        c(1+24*(n-1):24+24*(n-1)) = aux(25:48,n);
    end
end

%Se multiplican los valores para que se tenga un valor m�ximo de 400 y 600
%MW de generaci�n en la planta e�lica y solar.
aux = 0;
switch p(1,2)
    case 1
        while aux == 0
            fprintf('Seleccionar nivel de penetraci�n de energ�as renovables:\n');
            fprintf('1 =~ 51%% del caso de demanda m�xima (Generaci�n conjunta')
            fprintf(' m�xima: 1660 MW, promedio 500 MW)\n');
            fprintf('2 =~ 102%% del caso de demanda m�xima (Generaci�n conjunta');
            fprintf(' m�xima: 3319.7 MW, promedio 1000 MW)\n');
            s = input('Selecci�n: ');
            clc;
            if s == 1
                clc;
                fprintf('Datos cargados:\n');
                fprintf('Mes a simular: Agosto\n');
                fprintf('Demanda m�xima: 2775 MW\n');
                fprintf('Demanda promedio: 2263.1 MW\n');
                fprintf('Demanda m�nima: 1551.2 MW\n');
                fprintf('Generaci�n renovable m�xima: 1415.2 MW\n');
                fprintf('Generaci�n renovable promedio: 500 MW\n');
                e = 1.6599;
                aux = 1;
            elseif s == 2
                clc;
                fprintf('Datos cargados:\n');
                fprintf('Mes a simular: Agosto\n');
                fprintf('Demanda m�xima: 2775 MW\n');
                fprintf('Demanda promedio: 2263.1 MW\n');
                fprintf('Demanda m�nima: 1551.2 MW\n');
                fprintf('Generaci�n renovable m�xima: 2830.3 MW\n');
                fprintf('Generaci�n renovable promedio: 1000 MW\n');
                e = 3.3197;
                aux = 1;
            else
                fprintf('Selecci�n no v�lida, intente de nuevo.\n');
            end
        end
    case 2
        while aux == 0
            fprintf('Seleccionar nivel de penetraci�n de energ�as renovables:\n');
            fprintf('1 =~ 51%% del caso de demanda m�xima (Generaci�n conjunta')
            fprintf(' m�xima: 1387.5 MW, promedio 418 MW)\n');
            fprintf('2 =~ 102%% del caso de demanda m�xima (Generaci�n conjunta');
            fprintf(' m�xima: 2775 MW, promedio 835.9 MW)\n');
            s = input('Selecci�n: ');
            if s == 1
                clc;
                fprintf('Datos cargados:\n');
                fprintf('Mes a simular: Diciembre\n');
                fprintf('Demanda m�xima: 1650.4 MW\n');
                fprintf('Demanda promedio: 1305.7 MW\n');
                fprintf('Demanda m�nima: 862.5 MW\n');
                fprintf('Generaci�n renovable m�xima: 841.7 MW\n');
                fprintf('Generaci�n renovable promedio: 187.1 MW\n');
                e = 0.882376825;
                aux = 1;
            elseif s == 2
                clc;
                fprintf('Datos cargados:\n');
                fprintf('Mes a simular: Diciembre\n');
                fprintf('Demanda m�xima: 1650.4 MW\n');
                fprintf('Demanda promedio: 1305.7 MW\n');
                fprintf('Demanda m�nima: 862.5 MW\n');
                fprintf('Generaci�n renovable m�xima: 1683.5 MW\n');
                fprintf('Generaci�n renovable promedio: 374.3 MW\n');
                e = 1.76475365;
                aux = 1;
            else
                fprintf('Selecci�n no v�lida, intente de nuevo.\n');
            end
        end
end

%Se multiplican los valores de b y c por escalares para obtener los valores
%finales a utilizar, siendo b la generaci�n e�lica y c la generaci�n solar.
if p(1,2) == 1
    b = b*91.4115*e;
    c = c*13.7005*e;
else
    b = b*48.6773*e;
    c = c*14.3300*e;
end
%%

%Interpolaci�n de datos para obtener una resoluci�n de un segundo.
x = 1:744; xq = 1/3600:1/3600:744;

a = interp1(x,auxd,xq,'spline'); a = a';
b = interp1(x,b,xq,'spline'); b = b';
c = interp1(x,c,xq,'spline'); c = c';

dem = 1:length(xq); dem = dem';
gene = 1:length(xq); gene = gene';
gens = 1:length(xq); gens = gens';

dem(:,2) = a/1000;
gene(:,2) = b/1000;
gens(:,2) = c/1000;