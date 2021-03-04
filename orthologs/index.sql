use ellis2021;
alter table aaseqs DROP INDEX assemblyidFULL;
#alter table orthogroup DROP INDEX assemblyidFULL;


create index assemblyidFULL on aaseqs (assemblyid);
create index assemblyidFULL on orthogroup (assemblyid);




