close all;
clear all;
clc;

[~, parentPath ] =nnGenRootPath();

collection='MultiObject-Pinhole';

%mode = 'MultiExp_2_15';
mode='rawMC_2_15';
parameter = 'luxLevel';
% range = [100, 80, 60, 40, 20, 1];
range = {'0.0' '0.1', '1.0', '10.0', '100.0', '1000.0', '10000.0'};
% range={'mix'};

for r=1:length(range)
    level = range{r};

    test.shuffle = false;
    test.num_epochs = uint8(1);
    test.tf_record_input_reader.input_path = fullfile('/','scratch','Datasets',collection,sprintf('%s_%s_%s_test.record',mode, parameter, level));
    test.label_map_path = sprintf('/scratch/Datasets/%s/%s_label_map.pbtxt',collection,collection);
    
    fName = fullfile(parentPath,'Evaluations','Datasets',sprintf('%s_%s_%s_test.config',mode,parameter,level));
    struct2proto(test,fName);
    
    %%
    
    train.num_epochs = uint32(500);
    train.tf_record_input_reader.input_path = fullfile('/','scratch','Datasets',collection,sprintf('%s_%s_%s_trainval.record',mode, parameter, level));
    train.label_map_path = sprintf('/scratch/Datasets/%s/%s_label_map.pbtxt',collection,collection);
    
    fName = fullfile(parentPath,'Evaluations','Datasets',sprintf('%s_%s_%s_trainval.config',mode,parameter,level));
    struct2proto(train,fName);
    
    %%

    eval.max_evals = uint8(1);
    eval.num_examples = uint32(793);
    eval.num_visualizations = uint32(793);
    eval.visualization_export_dir = fullfile('/','scratch',sprintf('%s_%s_%s',mode,parameter,level),'images');
    
    fName = fullfile(parentPath,'Evaluations','Eval',sprintf('%s_%s_%s_eval.config',mode,parameter,level));
    struct2proto(eval,fName);
    
    
end
