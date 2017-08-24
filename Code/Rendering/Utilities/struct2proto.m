function struct2proto( in, fName)

fid = fopen(fName,'w');

recursiveStruct2proto(in,fid,'');

fclose(fid);

end

function recursiveStruct2proto(in, fid, prefix)


fields = fieldnames(in);
for i=1:length(fields)
    if isstruct(in.(fields{i}))
        fprintf(fid,'%s%s {\n',prefix,fields{i});
        recursiveStruct2proto(in.(fields{i}),fid,cat(1,'    ',prefix));
        fprintf(fid,'}\n');
    else
        if ischar(in.(fields{i}))
            fprintf(fid,'%s%s: "%s"\n',prefix,fields{i},in.(fields{i}));
        elseif islogical(in.(fields{i}))
            if in.(fields{i})
                fprintf(fid,'%s%s: true\n',prefix,fields{i});
            else
                fprintf(fid,'%s%s: false\n',prefix,fields{i});
            end
        elseif isinteger(in.(fields{i}))
            fprintf(fid,'%s%s: %i\n',prefix,fields{i},in.(fields{i}));
        else
            fprintf(fid,'%s%s: %f\n',prefix,fields{i},in.(fields{i}));
        end
        
    end
end


end

