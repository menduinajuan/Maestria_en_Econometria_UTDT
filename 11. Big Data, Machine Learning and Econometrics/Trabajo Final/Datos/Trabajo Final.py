    #!SECTION ##### IMPORTACIÓN DE DEPENDENCIAS #####


import subprocess
import sys
subprocess.run([sys.executable, "-m", "pip", "install", "-r", "requirements.txt"])

from matplotlib                 import style
from sklearn.compose            import ColumnTransformer
from sklearn.ensemble           import GradientBoostingRegressor, RandomForestRegressor, StackingRegressor
from sklearn.datasets           import fetch_california_housing
from sklearn.linear_model       import ElasticNet, Lasso, Ridge, RidgeCV
from sklearn.metrics            import mean_absolute_error, root_mean_squared_error, root_mean_squared_log_error, r2_score
from sklearn.model_selection    import RandomizedSearchCV, RepeatedKFold, train_test_split
from sklearn.neighbors          import KNeighborsRegressor
from sklearn.pipeline           import Pipeline
from sklearn.preprocessing      import StandardScaler

import matplotlib.pyplot as plt
import matplotlib.ticker as ticker
import multiprocessing as mp
import numpy as np
import os
import pandas as pd
import seaborn as sns
import warnings


    #!SECTION ##### DEFINICIÓN DE VARIABLES GLOBALES #####


PATH_RESULTS = "G:/Mi unidad/JM/Facultad de Ciencias Económicas (FCE)/Maestría en Econometría/11. Big Data, Machine Learning and Econometrics/Trabajo Final/Datos"
PATH_FIGURES = "G:/Mi unidad/JM/Facultad de Ciencias Económicas (FCE)/Maestría en Econometría/11. Big Data, Machine Learning and Econometrics/Trabajo Final/Figuras"
SEED = 12345


    #!SECTION ##### CONFIGURACIÓN DE PLOTEO #####


plt.rcParams["image.cmap"] = "bwr"
plt.rcParams["savefig.bbox"] = "tight"
style.use("ggplot") or plt.style.use("ggplot")
warnings.filterwarnings("ignore")


    #!SECTION ##### CARGA DE DATOS #####


data = fetch_california_housing(as_frame=True)
df = data.frame
column = df.pop("MedHouseVal")
df.insert(0, "MedHouseVal", column)
df.to_excel(f"{PATH_RESULTS}/california_housing.xlsx", index=False)
df.to_csv(f"{PATH_RESULTS}/california_housing.csv", index=False)


    #!SECTION ##### ANÁLISIS EXPLORATORIO #####


### Definición de funciones


def dataset_description(df):

    print("DIMENSIONES:", df.shape, "\n")
    print("TIPO DE DATOS Y VALORES NULOS:")
    df.info()
    print(" ")
    print("DATAFRAME (primeras 5 filas):\n", df.head(), "\n")
    print("RESUMEN ESTADÍSTICO:\n", df.describe(), "\n")
    print("CANTIDAD DE VALORES NULOS POR COLUMNA:\n", df.isna().sum().sort_values(), "\n")
    print("CANTIDAD DE FILAS DUPLICADAS:", df.duplicated().sum(), "\n")


def plot_target_distribution():

    fig, axes = plt.subplots(nrows=3, ncols=1, figsize=(6,6))

    sns.kdeplot(df["MedHouseVal"], fill=True, color="blue", ax=axes[0])
    sns.rugplot(df["MedHouseVal"], color="blue", ax=axes[0])
    axes[0].set_title("MedHouseVal", fontsize=10, fontweight="bold")
    axes[0].set_ylabel("Density", fontsize=6)
    axes[0].set_xlabel("MedHouseVal", fontsize=6)
    axes[0].tick_params(labelsize=6)

    sns.kdeplot(np.sqrt(df["MedHouseVal"]), fill=True, color="blue", ax=axes[1])
    sns.rugplot(np.sqrt(df["MedHouseVal"]), color="blue", ax=axes[1])
    axes[1].set_title("sqrt(MedHouseVal)", fontsize=10, fontweight="bold")
    axes[1].set_ylabel("Density", fontsize=6)
    axes[1].set_xlabel("sqrt(MedHouseVal)", fontsize=6)
    axes[1].tick_params(labelsize=6)

    sns.kdeplot(np.log(df["MedHouseVal"]), fill=True, color="blue", ax=axes[2])
    sns.rugplot(np.log(df["MedHouseVal"]), color="blue", ax=axes[2])
    axes[2].set_title("log(MedHouseVal)", fontsize=10, fontweight="bold")
    axes[2].set_ylabel("Density", fontsize=6)
    axes[2].set_xlabel("log(MedHouseVal)", fontsize=6)
    axes[2].tick_params(labelsize=6)

    fig.tight_layout()
    plt.subplots_adjust(top=0.9)


def plot_features_distribution():

    fig, axes = plt.subplots(nrows=2, ncols=4, figsize=(9,5))
    axes = axes.flat
    numeric_cols = df.select_dtypes(include=["int", "float64"]).columns.drop("MedHouseVal")

    for i, colum in enumerate(numeric_cols):
        sns.histplot(
            data     = df,
            x        = colum,
            stat     = "count",
            kde      = True,
            line_kws = {"linewidth": 2},
            color    = (list(plt.rcParams["axes.prop_cycle"])*2)[i]["color"],
            ax       = axes[i],
            alpha    = 0.3
        )
        axes[i].set_title(colum, fontsize=8, fontweight="bold")
        axes[i].set_ylabel("")
        axes[i].set_xlabel("")
        axes[i].tick_params(labelsize=6)

    fig.tight_layout()
    plt.subplots_adjust(top=0.9)


### Descripción general del dataset (antes de eliminar outliers)


dataset_description(df)
plot_target_distribution()
plot_features_distribution()
#plt.show()


### Eliminación de outliers (Método IQR)


q1 = df.quantile(0.25)
q3 = df.quantile(0.75)
iqr = q3-q1
df = df[~((df<(q1-1.5*iqr)) | (df>(q3+1.5*iqr))).any(axis=1)].reset_index(drop=True)


### Descripción general del dataset (después de eliminar outliers)


dataset_description(df)
plot_target_distribution()
plot_features_distribution()
#plt.show()


### Correlación entre la variable target y las features


fig, axes = plt.subplots(nrows=2, ncols=4, figsize=(9,5))
axes = axes.flat
numeric_cols = df.select_dtypes(include=["int", "float64"]).columns.drop("MedHouseVal")

for i, colum in enumerate(numeric_cols):
    sns.regplot(
        x           = df[colum],
        y           = df["MedHouseVal"],
        color       = "gray",
        marker      = ".",
        scatter_kws = {"alpha": 0.4},
        line_kws    = {"color": "red", "alpha": 0.8},
        ax          = axes[i]
    )
    axes[i].yaxis.set_major_formatter(ticker.EngFormatter())
    axes[i].xaxis.set_major_formatter(ticker.EngFormatter())
    axes[i].set_title(f"MedHouseVal vs {colum}", fontsize=8, fontweight="bold")
    axes[i].set_ylabel("")
    axes[i].set_xlabel("")
    axes[i].tick_params(labelsize=6)
    
fig.tight_layout()
plt.subplots_adjust(top=0.9)
#plt.show()


### Correlación entre todas las variables


def tidy_corr_matrix(corr_mat):
    corr_mat = corr_mat.stack().reset_index()
    corr_mat.columns = ["variable_1", "variable_2", "r"]
    corr_mat = corr_mat.loc[corr_mat["variable_1"]!=corr_mat["variable_2"], :]
    corr_mat["abs_r"] = np.abs(corr_mat["r"])
    corr_mat = corr_mat.sort_values("abs_r", ascending=False)
    return (corr_mat)

corr_matrix = df.select_dtypes(include=["int", "float64"]).corr(method="pearson")
print(tidy_corr_matrix(corr_matrix).head(10))


### Heatmap de correlaciones


fig, ax = plt.subplots(nrows=1, ncols=1, figsize=(4,4))

sns.heatmap(
    data      = corr_matrix,
    vmin      = -1,
    vmax      = 1,
    cmap      = sns.diverging_palette(20, 220, n=200),
    center    = 0,
    annot     = True,
    annot_kws = {"size": 6},
    cbar      = False,
    square    = True,
    ax        = ax
)

ax.set_xticklabels(ax.get_xticklabels(), rotation=45, horizontalalignment="right")
ax.tick_params(labelsize=6)

fig.tight_layout()
#plt.show()


    #!SECTION ##### DIVISIÓN DEL DATASET EN TRAIN Y TEST #####


X_train, X_test, y_train, y_test = train_test_split (
                                                        df.drop("MedHouseVal", axis="columns"),
                                                        df["MedHouseVal"],
                                                        train_size   = 0.8,
                                                        random_state = SEED
                                                    )

print("PARTICIÓN DE TRAIN:\n")
print(y_train.describe(), "\n")
print(X_train.describe(), "\n")
print(X_train.head(), "\n")

print("PARTICIÓN DE TEST:\n")
print(y_test.describe(), "\n")
print(X_test.describe(), "\n")
print(X_test.head(), "\n")


    #!SECTION ##### ALGORITMOS DE MACHINE LEARNING #####


### DEFINICIÓN DEL "PREPROCESSOR" PARA ESTANDARIZAR FEATURES NUMÉRICAS


numeric_cols = X_train.select_dtypes(include=["int", "float64"]).columns.to_list()
preprocessor = ColumnTransformer([("scale", StandardScaler(), numeric_cols)], remainder="passthrough", verbose_feature_names_out=False).set_output(transform="pandas")


### DEFINICIÓN DE FUNCIÓN PARA ENTRENAR Y EVALUAR MODELOS


def train_and_evaluate(model_name, model, hparams, X_train, y_train, X_test, y_test, preprocessor):

    print(f"\nCOMIENZA {model_name.upper()}\n")

    # Creación del pipeline
    pipeline = Pipeline([("preprocessing", preprocessor), ("model", model)])

    # Configuración de búsqueda de hiperparámetros óptimos
    grid_search = RandomizedSearchCV    (
                                            estimator           = pipeline,
                                            param_distributions = hparams,
                                            n_iter              = 50,
                                            scoring             = "neg_root_mean_squared_error",
                                            n_jobs              = mp.cpu_count()-1,
                                            refit               = True,
                                            cv                  = RepeatedKFold(n_splits=5, n_repeats=4),
                                            verbose             = 1,
                                            random_state        = SEED
                                        )

    # Entrenamiento del modelo
    grid_search.fit(X_train, y_train)

    # Hiperparámetros óptimos
    best_hparams = pd.DataFrame([grid_search.best_params_])
    best_hparams.insert(0, "Modelo", model_name)

    # Realización de predicciones
    best_model = grid_search.best_estimator_
    y_predictions = best_model.predict(X_test)

    # Cálculo de métricas
    metrics_test = pd.DataFrame ({
                                    "Modelo": [model_name],
                                    "MAE":    [mean_absolute_error(y_test, y_predictions)],
                                    "RMSE":   [root_mean_squared_error(y_test, y_predictions)],
                                    "RMSLE":  [root_mean_squared_log_error(y_test, y_predictions)],
                                    "R2":     [r2_score(y_test, y_predictions)]
                                })

    print(f"\nFINALIZA {model_name.upper()}\n")

    return (metrics_test, best_hparams)


### DEFINICIÓN DE MODELOS (K-Nearest Neighbors, Ridge, Lasso, Elastic Net, Random Forest y Gradient Boosting Trees) Y DE SUS HIPERPARÁMETROS POSIBLES


models =    [
                ("K-Nearest Neighbors",     KNeighborsRegressor(),      {"model__n_neighbors": np.linspace(1, 500, 250, dtype=int)}),
                ("Ridge",                   Ridge(),                    {"model__alpha": np.logspace(-4, 4, 250)}),
                ("Lasso",                   Lasso(),                    {"model__alpha": np.logspace(-4, 4, 250)}),
                ("Elastic Net",             ElasticNet(),               {"model__alpha": np.logspace(-4, 4, 250), "model__l1_ratio": np.linspace(0, 1, 250)}),
                ("Random Forest",           RandomForestRegressor(),    {"model__n_estimators": [50, 100, 250, 500], "model__max_features": [4, 5, 6, 7, 8], "model__max_depth": [5, 10, 15, 20]}),
                ("Gradient Boosting Trees", GradientBoostingRegressor(),{"model__n_estimators": [50, 100, 250, 500], "model__max_features": [4, 5, 6, 7, 8], "model__max_depth": [5, 10, 15, 20], "model__subsample": [0.25, 0.5, 0.75, 1.0]})
            ]


### ENTRENAMIENTO Y EVALUACIÓN DE CADA MODELO


df_metrics_test_list, df_best_hparams_list = zip(*[train_and_evaluate(model_name, model, hparams, X_train, y_train, X_test, y_test, preprocessor) for model_name, model, hparams in models])
df_metrics_test = pd.concat(df_metrics_test_list, ignore_index=True)
df_best_hparams = pd.concat(df_best_hparams_list, ignore_index=True)


### ENTRENAMIENTO Y EVALUACIÓN DEL STACKING (ALGORITMO SUPER LEARNER)


print("\nCOMIENZA STACKING\n")

# Creación de los pipelines
pipelines = {
                "knn":                      Pipeline([("preprocessing", preprocessor), ("knn",                     KNeighborsRegressor(n_neighbors=df_best_hparams_list[0]["model__n_neighbors"].values[0]))]),
                "ridge":                    Pipeline([("preprocessing", preprocessor), ("ridge",                   Ridge(alpha=df_best_hparams_list[1]["model__alpha"].values[0]))]),
                "lasso":                    Pipeline([("preprocessing", preprocessor), ("lasso",                   Lasso(alpha=df_best_hparams_list[2]["model__alpha"].values[0]))]),
                "elastic_net":              Pipeline([("preprocessing", preprocessor), ("elastic_net",             ElasticNet(alpha=df_best_hparams_list[3]["model__alpha"].values[0], l1_ratio=df_best_hparams_list[3]["model__l1_ratio"].values[0]))]),
                "random_forest":            Pipeline([("preprocessing", preprocessor), ("random_forest",           RandomForestRegressor(n_estimators=df_best_hparams_list[4]["model__n_estimators"].values[0], max_features=df_best_hparams_list[4]["model__max_features"].values[0], max_depth=df_best_hparams_list[4]["model__max_depth"].values[0]))]),
                "gradient_boosting_trees":  Pipeline([("preprocessing", preprocessor), ("gradient_boosting_trees", GradientBoostingRegressor(n_estimators=df_best_hparams_list[5]["model__n_estimators"].values[0], max_features=df_best_hparams_list[5]["model__max_features"].values[0], max_depth=df_best_hparams_list[5]["model__max_depth"].values[0], subsample=df_best_hparams_list[5]["model__subsample"].values[0]))])
            }

# Entrenamiento del modelo
stacking = StackingRegressor    (
                                    estimators      = [(name, pipeline) for name, pipeline in pipelines.items()],
                                    final_estimator = RidgeCV(),
                                    n_jobs          = mp.cpu_count()-1,
                                    verbose         = 1
                                )
stacking.fit(X_train, y_train)

# Realización de predicciones
best_model = stacking
y_predictions = best_model.predict(X_test)

# Cálculo de métricas
metrics_test = pd.DataFrame ({
                                "Modelo": ["Stacking"],
                                "MAE":    [mean_absolute_error(y_test, y_predictions)],
                                "RMSE":   [root_mean_squared_error(y_test, y_predictions)],
                                "RMSLE":  [root_mean_squared_log_error(y_test, y_predictions)],
                                "R2":     [r2_score(y_test, y_predictions)]
                            })

print("\nFINALIZA STACKING\n")

df_metrics_test = pd.concat([df_metrics_test, metrics_test], ignore_index=True)


### VISUALIZACIÓN Y GUARDADO DE RESULTADOS FINALES


print("DATAFRAME MÉTRICAS TEST:\n", df_metrics_test, "\n")
print("DATAFRAME HIPERPARÁMETROS ÓPTIMOS:\n", df_best_hparams, "\n")

df_metrics_test.to_excel(f"{PATH_RESULTS}/results_metrics_test.xlsx", index=False)
df_best_hparams.to_excel(f"{PATH_RESULTS}/results_best_hparams.xlsx", index=False)

metrics = ["MAE", "RMSE", "RMSLE", "R2"]

for metric in metrics:
    df_metric_test = df_metrics_test[["Modelo", metric]].sort_values(metric, ascending=(metric=="R2"))
    fig, ax = plt.subplots(figsize=(6,4))
    ax.hlines(df_metric_test["Modelo"], xmin=0, xmax=df_metric_test[metric])
    ax.plot(df_metric_test[metric], df_metric_test["Modelo"], "o", color="black")
    ax.set_title(f"{metric}", fontsize=12, fontweight="bold")
    ax.set_xlabel(f"{metric}", fontsize=8)
    ax.tick_params(labelsize=8)
    fig.tight_layout()
    fig.savefig(os.path.join(PATH_FIGURES, f"metric_test_{metric}.png"), dpi=300, bbox_inches="tight")

#plt.show()