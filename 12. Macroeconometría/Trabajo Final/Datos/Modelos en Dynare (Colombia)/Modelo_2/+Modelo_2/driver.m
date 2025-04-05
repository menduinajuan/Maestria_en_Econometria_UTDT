%
% Status : main Dynare file
%
% Warning : this file is generated automatically by Dynare
%           from model file (.mod)

clearvars -global
clear_persistent_variables(fileparts(which('dynare')), false)
tic0 = tic;
% Define global variables.
global M_ options_ oo_ estim_params_ bayestopt_ dataset_ dataset_info estimation_info
options_ = [];
M_.fname = 'Modelo_2';
M_.dynare_version = '6.2';
oo_.dynare_version = '6.2';
options_.dynare_version = '6.2';
%
% Some global variables initialization
%
global_initialization;
M_.exo_names = cell(1,1);
M_.exo_names_tex = cell(1,1);
M_.exo_names_long = cell(1,1);
M_.exo_names(1) = {'e'};
M_.exo_names_tex(1) = {'e'};
M_.exo_names_long(1) = {'e'};
M_.endo_names = cell(13,1);
M_.endo_names_tex = cell(13,1);
M_.endo_names_long = cell(13,1);
M_.endo_names(1) = {'y'};
M_.endo_names_tex(1) = {'y'};
M_.endo_names_long(1) = {'y'};
M_.endo_names(2) = {'c'};
M_.endo_names_tex(2) = {'c'};
M_.endo_names_long(2) = {'c'};
M_.endo_names(3) = {'k'};
M_.endo_names_tex(3) = {'k'};
M_.endo_names_long(3) = {'k'};
M_.endo_names(4) = {'i'};
M_.endo_names_tex(4) = {'i'};
M_.endo_names_long(4) = {'i'};
M_.endo_names(5) = {'h'};
M_.endo_names_tex(5) = {'h'};
M_.endo_names_long(5) = {'h'};
M_.endo_names(6) = {'A'};
M_.endo_names_tex(6) = {'A'};
M_.endo_names_long(6) = {'A'};
M_.endo_names(7) = {'y_h'};
M_.endo_names_tex(7) = {'y\_h'};
M_.endo_names_long(7) = {'y_h'};
M_.endo_names(8) = {'w'};
M_.endo_names_tex(8) = {'w'};
M_.endo_names_long(8) = {'w'};
M_.endo_names(9) = {'d'};
M_.endo_names_tex(9) = {'d'};
M_.endo_names_long(9) = {'d'};
M_.endo_names(10) = {'tb'};
M_.endo_names_tex(10) = {'tb'};
M_.endo_names_long(10) = {'tb'};
M_.endo_names(11) = {'ca'};
M_.endo_names_tex(11) = {'ca'};
M_.endo_names_long(11) = {'ca'};
M_.endo_names(12) = {'p'};
M_.endo_names_tex(12) = {'p'};
M_.endo_names_long(12) = {'p'};
M_.endo_names(13) = {'r'};
M_.endo_names_tex(13) = {'r'};
M_.endo_names_long(13) = {'r'};
M_.endo_partitions = struct();
M_.param_names = cell(11,1);
M_.param_names_tex = cell(11,1);
M_.param_names_long = cell(11,1);
M_.param_names(1) = {'alpha'};
M_.param_names_tex(1) = {'alpha'};
M_.param_names_long(1) = {'alpha'};
M_.param_names(2) = {'delta'};
M_.param_names_tex(2) = {'delta'};
M_.param_names_long(2) = {'delta'};
M_.param_names(3) = {'gamma'};
M_.param_names_tex(3) = {'gamma'};
M_.param_names_long(3) = {'gamma'};
M_.param_names(4) = {'omega'};
M_.param_names_tex(4) = {'omega'};
M_.param_names_long(4) = {'omega'};
M_.param_names(5) = {'phi'};
M_.param_names_tex(5) = {'phi'};
M_.param_names_long(5) = {'phi'};
M_.param_names(6) = {'rho'};
M_.param_names_tex(6) = {'rho'};
M_.param_names_long(6) = {'rho'};
M_.param_names(7) = {'rstar'};
M_.param_names_tex(7) = {'rstar'};
M_.param_names_long(7) = {'rstar'};
M_.param_names(8) = {'sigmae'};
M_.param_names_tex(8) = {'sigmae'};
M_.param_names_long(8) = {'sigmae'};
M_.param_names(9) = {'beta'};
M_.param_names_tex(9) = {'beta'};
M_.param_names_long(9) = {'beta'};
M_.param_names(10) = {'dbar'};
M_.param_names_tex(10) = {'dbar'};
M_.param_names_long(10) = {'dbar'};
M_.param_names(11) = {'psi2'};
M_.param_names_tex(11) = {'psi2'};
M_.param_names_long(11) = {'psi2'};
M_.param_partitions = struct();
M_.exo_det_nbr = 0;
M_.exo_nbr = 1;
M_.endo_nbr = 13;
M_.param_nbr = 11;
M_.orig_endo_nbr = 13;
M_.aux_vars = [];
M_.Sigma_e = zeros(1, 1);
M_.Correlation_matrix = eye(1, 1);
M_.H = 0;
M_.Correlation_matrix_ME = 1;
M_.sigma_e_is_diagonal = true;
M_.det_shocks = [];
M_.surprise_shocks = [];
M_.learnt_shocks = [];
M_.learnt_endval = [];
M_.heteroskedastic_shocks.Qvalue_orig = [];
M_.heteroskedastic_shocks.Qscale_orig = [];
M_.matched_irfs = {};
M_.matched_irfs_weights = {};
options_.linear = false;
options_.block = false;
options_.bytecode = false;
options_.use_dll = false;
options_.ramsey_policy = false;
options_.discretionary_policy = false;
M_.eq_nbr = 13;
M_.ramsey_orig_eq_nbr = 0;
M_.ramsey_orig_endo_nbr = 0;
M_.set_auxiliary_variables = exist(['./+' M_.fname '/set_auxiliary_variables.m'], 'file') == 2;
M_.epilogue_names = {};
M_.epilogue_var_list_ = {};
M_.orig_maximum_endo_lag = 1;
M_.orig_maximum_endo_lead = 1;
M_.orig_maximum_exo_lag = 0;
M_.orig_maximum_exo_lead = 0;
M_.orig_maximum_exo_det_lag = 0;
M_.orig_maximum_exo_det_lead = 0;
M_.orig_maximum_lag = 1;
M_.orig_maximum_lead = 1;
M_.orig_maximum_lag_with_diffs_expanded = 1;
M_.lead_lag_incidence = [
 0 4 17;
 0 5 18;
 1 6 19;
 0 7 0;
 0 8 20;
 2 9 0;
 0 10 0;
 0 11 0;
 3 12 0;
 0 13 0;
 0 14 0;
 0 15 0;
 0 16 0;]';
M_.nstatic = 7;
M_.nfwrd   = 3;
M_.npred   = 2;
M_.nboth   = 1;
M_.nsfwrd   = 4;
M_.nspred   = 3;
M_.ndynamic   = 6;
M_.dynamic_tmp_nbr = [10; 4; 0; 0; ];
M_.equations_tags = {
  1 , 'name' , '1' ;
  2 , 'name' , '2' ;
  3 , 'name' , '3' ;
  4 , 'name' , '4' ;
  5 , 'name' , 'y' ;
  6 , 'name' , 'p' ;
  7 , 'name' , 'k' ;
  8 , 'name' , '8' ;
  9 , 'name' , 'tb' ;
  10 , 'name' , 'ca' ;
  11 , 'name' , 'y_h' ;
  12 , 'name' , 'r' ;
  13 , 'name' , 'w' ;
};
M_.mapping.y.eqidx = [1 2 4 5 9 11 13 ];
M_.mapping.c.eqidx = [2 3 4 9 ];
M_.mapping.k.eqidx = [2 4 5 7 9 ];
M_.mapping.i.eqidx = [4 7 9 ];
M_.mapping.h.eqidx = [1 2 3 5 11 13 ];
M_.mapping.A.eqidx = [5 8 ];
M_.mapping.y_h.eqidx = [11 ];
M_.mapping.w.eqidx = [13 ];
M_.mapping.d.eqidx = [4 6 10 ];
M_.mapping.tb.eqidx = [9 10 ];
M_.mapping.ca.eqidx = [10 ];
M_.mapping.p.eqidx = [6 12 ];
M_.mapping.r.eqidx = [3 4 10 12 ];
M_.mapping.e.eqidx = [8 ];
M_.static_and_dynamic_models_differ = false;
M_.has_external_function = false;
M_.block_structure.time_recursive = false;
M_.block_structure.block(1).Simulation_Type = 3;
M_.block_structure.block(1).endo_nbr = 1;
M_.block_structure.block(1).mfs = 1;
M_.block_structure.block(1).equation = [ 8];
M_.block_structure.block(1).variable = [ 6];
M_.block_structure.block(1).is_linear = false;
M_.block_structure.block(1).NNZDerivatives = 2;
M_.block_structure.block(1).bytecode_jacob_cols_to_sparse = [0 1 ];
M_.block_structure.block(2).Simulation_Type = 8;
M_.block_structure.block(2).endo_nbr = 8;
M_.block_structure.block(2).mfs = 7;
M_.block_structure.block(2).equation = [ 12 6 7 4 2 3 5 1];
M_.block_structure.block(2).variable = [ 13 12 4 9 3 2 1 5];
M_.block_structure.block(2).is_linear = false;
M_.block_structure.block(2).NNZDerivatives = 33;
M_.block_structure.block(2).bytecode_jacob_cols_to_sparse = [3 4 0 8 9 10 11 12 13 14 18 19 20 21 ];
M_.block_structure.block(3).Simulation_Type = 1;
M_.block_structure.block(3).endo_nbr = 4;
M_.block_structure.block(3).mfs = 4;
M_.block_structure.block(3).equation = [ 13 9 11 10];
M_.block_structure.block(3).variable = [ 8 10 7 11];
M_.block_structure.block(3).is_linear = true;
M_.block_structure.block(3).NNZDerivatives = 5;
M_.block_structure.block(3).bytecode_jacob_cols_to_sparse = [5 6 7 8 ];
M_.block_structure.block(1).g1_sparse_rowval = int32([1 ]);
M_.block_structure.block(1).g1_sparse_colval = int32([1 ]);
M_.block_structure.block(1).g1_sparse_colptr = int32([1 2 ]);
M_.block_structure.block(2).g1_sparse_rowval = int32([1 3 2 3 4 6 1 3 5 2 3 3 2 3 4 3 4 5 3 6 7 4 5 6 7 4 4 5 4 4 5 ]);
M_.block_structure.block(2).g1_sparse_colval = int32([3 3 4 4 4 4 8 8 8 9 9 10 11 11 11 12 12 12 13 13 13 14 14 14 14 18 19 19 20 21 21 ]);
M_.block_structure.block(2).g1_sparse_colptr = int32([1 1 1 3 7 7 7 7 10 12 13 16 19 22 26 26 26 26 27 29 30 32 ]);
M_.block_structure.block(3).g1_sparse_rowval = int32([]);
M_.block_structure.block(3).g1_sparse_colval = int32([]);
M_.block_structure.block(3).g1_sparse_colptr = int32([]);
M_.block_structure.variable_reordered = [ 6 13 12 4 9 3 2 1 5 8 10 7 11];
M_.block_structure.equation_reordered = [ 8 12 6 7 4 2 3 5 1 13 9 11 10];
M_.block_structure.incidence(1).lead_lag = -1;
M_.block_structure.incidence(1).sparse_IM = [
 2 3;
 4 3;
 4 9;
 5 3;
 6 9;
 7 3;
 8 6;
 9 3;
 10 9;
];
M_.block_structure.incidence(2).lead_lag = 0;
M_.block_structure.incidence(2).sparse_IM = [
 1 1;
 1 5;
 2 2;
 2 3;
 2 5;
 3 2;
 3 5;
 3 13;
 4 1;
 4 2;
 4 3;
 4 4;
 4 9;
 4 13;
 5 1;
 5 5;
 5 6;
 6 12;
 7 3;
 7 4;
 8 6;
 9 1;
 9 2;
 9 3;
 9 4;
 9 10;
 10 10;
 10 11;
 10 13;
 11 1;
 11 5;
 11 7;
 12 12;
 12 13;
 13 1;
 13 5;
 13 8;
];
M_.block_structure.incidence(3).lead_lag = 1;
M_.block_structure.incidence(3).sparse_IM = [
 2 1;
 2 2;
 2 3;
 2 5;
 3 2;
 3 5;
];
M_.block_structure.dyn_tmp_nbr = 12;
M_.state_var = [6 9 3 ];
M_.maximum_lag = 1;
M_.maximum_lead = 1;
M_.maximum_endo_lag = 1;
M_.maximum_endo_lead = 1;
oo_.steady_state = zeros(13, 1);
M_.maximum_exo_lag = 0;
M_.maximum_exo_lead = 0;
oo_.exo_steady_state = zeros(1, 1);
M_.params = NaN(11, 1);
M_.endo_trends = struct('deflator', cell(13, 1), 'log_deflator', cell(13, 1), 'growth_factor', cell(13, 1), 'log_growth_factor', cell(13, 1));
M_.NNZDerivatives = [53; -1; -1; ];
M_.dynamic_g1_sparse_rowval = int32([2 4 5 7 9 8 4 6 10 1 4 5 9 11 13 2 3 4 9 2 4 7 9 4 7 9 1 2 3 5 11 13 5 8 11 13 4 9 10 10 6 12 3 4 10 12 2 2 3 2 2 3 8 ]);
M_.dynamic_g1_sparse_colval = int32([3 3 3 3 3 6 9 9 9 14 14 14 14 14 14 15 15 15 15 16 16 16 16 17 17 17 18 18 18 18 18 18 19 19 20 21 22 23 23 24 25 25 26 26 26 26 27 28 28 29 31 31 40 ]);
M_.dynamic_g1_sparse_colptr = int32([1 1 1 6 6 6 7 7 7 10 10 10 10 10 16 20 24 27 33 35 36 37 38 40 41 43 47 48 50 51 51 53 53 53 53 53 53 53 53 53 54 ]);
M_.lhs = {
'h^(omega-1)'; 
'(c-h^omega/omega)^(-gamma)'; 
'(c-h^omega/omega)^(-gamma)'; 
'c+i+phi/2*(k-k(-1))^2+(1+r)*d(-1)'; 
'y'; 
'p'; 
'k'; 
'log(A)'; 
'tb'; 
'ca'; 
'y_h'; 
'r'; 
'w'; 
};
M_.static_tmp_nbr = [6; 2; 0; 0; ];
M_.block_structure_stat.block(1).Simulation_Type = 3;
M_.block_structure_stat.block(1).endo_nbr = 1;
M_.block_structure_stat.block(1).mfs = 1;
M_.block_structure_stat.block(1).equation = [ 8];
M_.block_structure_stat.block(1).variable = [ 6];
M_.block_structure_stat.block(2).Simulation_Type = 6;
M_.block_structure_stat.block(2).endo_nbr = 8;
M_.block_structure_stat.block(2).mfs = 8;
M_.block_structure_stat.block(2).equation = [ 2 3 4 5 6 7 1 12];
M_.block_structure_stat.block(2).variable = [ 2 13 4 5 9 3 1 12];
M_.block_structure_stat.block(3).Simulation_Type = 1;
M_.block_structure_stat.block(3).endo_nbr = 4;
M_.block_structure_stat.block(3).mfs = 4;
M_.block_structure_stat.block(3).equation = [ 13 9 11 10];
M_.block_structure_stat.block(3).variable = [ 8 10 7 11];
M_.block_structure_stat.variable_reordered = [ 6 2 13 4 5 9 3 1 12 8 10 7 11];
M_.block_structure_stat.equation_reordered = [ 8 2 3 4 5 6 7 1 12 13 9 11 10];
M_.block_structure_stat.incidence.sparse_IM = [
 1 1;
 1 5;
 2 1;
 2 2;
 2 3;
 2 5;
 3 2;
 3 5;
 3 13;
 4 1;
 4 2;
 4 4;
 4 9;
 4 13;
 5 1;
 5 3;
 5 5;
 5 6;
 6 9;
 6 12;
 7 3;
 7 4;
 8 6;
 9 1;
 9 2;
 9 4;
 9 10;
 10 9;
 10 10;
 10 11;
 10 13;
 11 1;
 11 5;
 11 7;
 12 12;
 12 13;
 13 1;
 13 5;
 13 8;
];
M_.block_structure_stat.tmp_nbr = 8;
M_.block_structure_stat.block(1).g1_sparse_rowval = int32([1 ]);
M_.block_structure_stat.block(1).g1_sparse_colval = int32([1 ]);
M_.block_structure_stat.block(1).g1_sparse_colptr = int32([1 2 ]);
M_.block_structure_stat.block(2).g1_sparse_rowval = int32([1 2 3 2 3 8 3 6 1 2 4 7 3 5 1 4 6 1 3 4 7 5 8 ]);
M_.block_structure_stat.block(2).g1_sparse_colval = int32([1 1 1 2 2 2 3 3 4 4 4 4 5 5 6 6 6 7 7 7 7 8 8 ]);
M_.block_structure_stat.block(2).g1_sparse_colptr = int32([1 4 7 9 13 15 18 22 24 ]);
M_.block_structure_stat.block(3).g1_sparse_rowval = int32([]);
M_.block_structure_stat.block(3).g1_sparse_colval = int32([]);
M_.block_structure_stat.block(3).g1_sparse_colptr = int32([]);
M_.static_g1_sparse_rowval = int32([1 2 4 5 9 11 13 2 3 4 9 2 5 7 4 7 9 1 2 3 5 11 13 5 8 11 13 4 6 10 9 10 10 6 12 3 4 10 12 ]);
M_.static_g1_sparse_colval = int32([1 1 1 1 1 1 1 2 2 2 2 3 3 3 4 4 4 5 5 5 5 5 5 6 6 7 8 9 9 9 10 10 11 12 12 13 13 13 13 ]);
M_.static_g1_sparse_colptr = int32([1 8 12 15 18 24 26 27 28 31 33 34 36 40 ]);
M_.params(1) = 0.33;
alpha = M_.params(1);
M_.params(2) = 0.0532;
delta = M_.params(2);
M_.params(3) = 0.316;
gamma = M_.params(3);
M_.params(4) = 1.7;
omega = M_.params(4);
M_.params(5) = 0.028;
phi = M_.params(5);
M_.params(6) = 0.811;
rho = M_.params(6);
M_.params(7) = 0.0484;
rstar = M_.params(7);
M_.params(8) = 0.0129;
sigmae = M_.params(8);
M_.params(9) = 1/(1+M_.params(7));
beta = M_.params(9);
M_.params(10) = 0.5725;
dbar = M_.params(10);
M_.params(11) = 0.0007423333333333333;
psi2 = M_.params(11);
%
% INITVAL instructions
%
options_.initval_file = false;
oo_.steady_state(3) = 5;
oo_.steady_state(2) = 1.12;
oo_.steady_state(5) = 1.0074;
oo_.steady_state(9) = 0.5725;
oo_.steady_state(6) = 1;
oo_.exo_steady_state(1) = 0;
if M_.exo_nbr > 0
	oo_.exo_simul = ones(M_.maximum_lag,1)*oo_.exo_steady_state';
end
if M_.exo_det_nbr > 0
	oo_.exo_det_simul = ones(M_.maximum_lag,1)*oo_.exo_det_steady_state';
end
%
% SHOCKS instructions
%
M_.exo_det_length = 0;
M_.Sigma_e(1, 1) = M_.params(8)^2;
steady;
options_.irf = 10;
options_.order = 1;
var_list_ = {};
[info, oo_, options_, M_] = stoch_simul(M_, options_, oo_, var_list_);
statistic = 100*sqrt(diag(oo_.var(1:13,1:13)))./oo_.mean(1:13);
disp(' ');
disp('----------------------------------');
disp('Relative Standard Deviations in %');
disp('----------------------------------');
disp('VARIABLE        REL. STD. DEV.');
for i = 1:13
fprintf('%-10s    %8.3f\n', M_.endo_names{i}, statistic(i));
end;


oo_.time = toc(tic0);
disp(['Total computing time : ' dynsec2hms(oo_.time) ]);
if ~exist([M_.dname filesep 'Output'],'dir')
    mkdir(M_.dname,'Output');
end
save([M_.dname filesep 'Output' filesep 'Modelo_2_results.mat'], 'oo_', 'M_', 'options_');
if exist('estim_params_', 'var') == 1
  save([M_.dname filesep 'Output' filesep 'Modelo_2_results.mat'], 'estim_params_', '-append');
end
if exist('bayestopt_', 'var') == 1
  save([M_.dname filesep 'Output' filesep 'Modelo_2_results.mat'], 'bayestopt_', '-append');
end
if exist('dataset_', 'var') == 1
  save([M_.dname filesep 'Output' filesep 'Modelo_2_results.mat'], 'dataset_', '-append');
end
if exist('estimation_info', 'var') == 1
  save([M_.dname filesep 'Output' filesep 'Modelo_2_results.mat'], 'estimation_info', '-append');
end
if exist('dataset_info', 'var') == 1
  save([M_.dname filesep 'Output' filesep 'Modelo_2_results.mat'], 'dataset_info', '-append');
end
if exist('oo_recursive_', 'var') == 1
  save([M_.dname filesep 'Output' filesep 'Modelo_2_results.mat'], 'oo_recursive_', '-append');
end
if exist('options_mom_', 'var') == 1
  save([M_.dname filesep 'Output' filesep 'Modelo_2_results.mat'], 'options_mom_', '-append');
end
if ~isempty(lastwarn)
  disp('Note: warning(s) encountered in MATLAB/Octave code')
end
