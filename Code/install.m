close all;
clear all;
clc;

[ codePath, parentPath ] = nnGenRootPath();

addpath(codePath);
addpath(fullfile(codePath,'Rendering'));
addpath(fullfile(codePath,'Rendering','Utilities'));
addpath(fullfile(codePath,'Rendering','Remodellers'));

