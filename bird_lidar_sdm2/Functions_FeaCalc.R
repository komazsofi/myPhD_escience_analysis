"
@author: Zsofia Koma, UvA
Aim: Feature caculation functions (based on Tristan article)
"

eigenmetrics = function(X,Y,Z)
{
  xyz=cbind(X,Y,Z) 
  cov_m=cov(xyz) 
  
  if(sum(is.na(cov_m))==0) {
    
    eigen_m=eigen(cov_m)
    
    shapemetrics = list(
      curvature = eigen_m$values[3]/(eigen_m$values[1]+eigen_m$values[2]+eigen_m$values[3]),
      linearity = (eigen_m$values[1]-eigen_m$values[2])/eigen_m$values[1],
      planarity = (eigen_m$values[2]-eigen_m$values[3])/eigen_m$values[1],
      sphericity = eigen_m$values[3]/eigen_m$values[1]
    )
    return(shapemetrics)
  }
}

coverageMetrics = function(z,classification)
{
  coveragemetrics = list(
    pulsepen_ground = (length(z[classification==2])/length(z))*100,
    cancov = (length(z[z>mean(z)])/length(z))*100,
    dens_perc_b2 = (length(z[classification==1 & z<2])/length(z))*100,
    dens_perc_b2_5 = (length(z[classification==1 & z>2 & z<5])/length(z))*100
  )
  return(coveragemetrics)
}

proportion = function(z, by = 1, zmax = NULL)
{
  # Fixed 
  if (is.null(zmax))
    zmax = max(z)
  
  if (zmax < 0.000001 * by)
    return(NA_real_)
  
  if (min(z) < 0)
    return(NA_real_)
  
  # Define the number of x meters bins from 0 to zmax (rounded to the next integer)
  bk = seq(0, ceiling(zmax/by)*by, by)
  
  # Compute the p for each bin
  hist = hist(z,bk,plot=FALSE)
  
  # Proportion
  p=(hist$counts/length(z))
  
  return(p)
}


vertDistr_Metrics = function(z)
{
  library("e1071")
  
  p=proportion(z, by = 1, zmax = NULL)
  p_whnull=p[p>0]
  
  vertdistr_metrics = list(
    zstd = sd(z),
    zvar = var(z),
    zskew = skewness(z),
    zkurto = kurtosis(z),
    canrelrat = (mean(z)-min(z))/max(z)-min(z),
    vertdenrat = (max(z)-median(z))/max(z),
    simpson = 1/sum(sqrt(p)),
    shannon = -sum(p_whnull*log(p_whnull))
  )
  return(vertdistr_metrics)
}

HeightMetrics = function(z)
{
  
  heightmetrics = list(
    zmax = max(z), 
    zmean = mean(z),
    zmedian = median(z),
    z025quantile = quantile(z, 0.25),
    z075quantile = quantile(z, 0.75),
    z090quantile = quantile(z, 0.90),
    zcoeffvar = sd(z)/mean(z),
    zmin = min(z)
  )
  return(heightmetrics)
}