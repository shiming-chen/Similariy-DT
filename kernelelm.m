%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This file is used for model learning 

%%%%    AUTHOR:         Dr. Shiming Chen
%%%%    ORGANIZATION    Huazhong University of Science and Technology (HUST), China
%%%%    EMAIL:          shimingchen@hust.edu.cn
%%%%    WEBSITE:        https://shiming-chen.github.io
%%%%    DATE:           November 2019
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [OutputWeight] = kernelelm(Y,N, Regularization_factor, Kernel_type, Kernel_coefficient)

% Usage: elm(TrainingData_File, TestingData_File, Elm_Type, NumberofHiddenNeurons, ActivationFunction)
% OR:    [TrainingTime, TestingTime, TrainingAccuracy, TestingAccuracy] = elm(TrainingData_File, TestingData_File, Elm_Type, NumberofHiddenNeurons, ActivationFunction)
%
% Input:
% Y                           - training data set
% N                           - The length of frames of training data 
% Regularization_factor       - Regularization coefficient C
% Kernel_type                 - Type of Kernels:
%                                   'RBF_kernel' for RBF Kernel
%                                   'lin_kernel' for Linear Kernel
%                                   'poly_kernel' for Polynomial Kernel
%                                   'ratquad_kernel' for Rational Quadratic kernel
%                                   'sigmoid_kernel' for Rational Sigmoid kernel
%                                   'multiquadric_kernel' for Multiquadric kernel
%Kernel_coefficient                  - A number or vector of Kernel Parameters. eg. 1, [0.1,10]...

% Output: 
% OutputWeight                - the learned output weight of kernel-ELM





                              
T=Y(2:N,:)';
P=Y(1:N-1,:)';
C = Regularization_factor;
n = size(T,2);
Omega_train = kernel_matrix(P',Kernel_type, Kernel_coefficient);

OutputWeight=((Omega_train+speye(n)*C)\(T')); 

    

