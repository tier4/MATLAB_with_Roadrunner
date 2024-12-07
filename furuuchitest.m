v = [3, 4 , 12];
magnitude = norm(v);
disp(magnitude)
Field = 'd';
data = struct(Field, []);
data.(Field)(1).time = 1000;
data.(Field)(1).v = 1000;
data.(Field)(2).v = 2000;
data.newld = 123;
data1 = [1,2,3];
data2 = [2,3,4];
disp(data1 - data2)
disp(data)