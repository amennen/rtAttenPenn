/*
 *  Name:		 highpass_gaussian_betweenruns.c
 *  Description: high-passes the entire time series of each voxel according to fsl's method 
 *				 1. convolving the time series with a gaussian (retrieving the low frequency drift)
 *				 2. subtracting that gaussian (leaving only the high frequency components)
 *				 
 *  Inputs:		 raw_data = raw bold patterns [timepoints x voxels]
 *				 sigma	 = standard deviation of the gaussian 
 * 
 *  Outputs:	 filt_data = filtered bold patterns [timepoints x voxels] 
 *
 *  Notes:		 this method is derived from the fslmaths -bptf option, the source code can be found in
 *				 lines 2121-2226 of $FSLDIR/src/newimage/newimagefns.h
 * 
 *  Written by:	 MdB 8/2011
 */


// header files to include - might not need all of them... 
#include <stdlib.h>
#include <math.h>
#include <mex.h>
#include <matrix.h>
#include <tmwtypes.h>
#include <string.h>

// define the other routines to call, double = returns something, void = does not return anything
void hp_filter(const double *raw_data, const int sigma, double *filtered_data, mwSize nt, mwSize nv);
void hp_convkernel(double *hp_exp, const int hp_mask_size, const int sigma);
double get_max_val(const int input1, const int input2);
double get_min_val(const int input1, const int input2);

// mex function - parse inputs from matlab workspace
void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{

	int sigma;
	double *raw_data, *filtered_data;
	mwSize nt, nv;
	
	if (nrhs != 2) // check that the number of inputs is 2 (raw_data and sigma)
		mexErrMsgTxt("The number of input arguments must be 2");
	
	if (nlhs != 1) // check that the number of outputs is 1 (filtered_data)
		mexErrMsgTxt("The number of output arguments must be 1");
	
	raw_data	 = mxGetPr(prhs[0]);					 //raw patterns matrix [timepoints x voxels]
	nt			 = mxGetM(prhs[0]);						 //number of timepoints (rows) of the raw patterns
	nv			 = mxGetN(prhs[0]);						 //number of voxels (columns) of the raw patterns
	sigma		 = mxGetScalar(prhs[1]);				 //standard deviation of the gaussian filter
	plhs[0]		 = mxCreateDoubleMatrix(nt, nv, mxREAL); //define the filtered patterns output matrix [timepoints x voxels]
	filtered_data= mxGetPr(plhs[0]);					 //retrieve the pointer to the filtered patterns output matrix
	
	hp_filter(raw_data,sigma, filtered_data,nt,nv);
}

// filter the data
void hp_filter(const double *raw_data, const int sigma, double *filtered_data, mwSize nt, mwSize nv)
{
	
	
	int t, hp_mask_size, tt, v, done_c0;
	mxArray *hp_exp_array, *voxel_rawtimeseries_array, *voxel_filteredtimeseries_array;
	double *hp_exp, *voxel_rawtimeseries, c0, *voxel_filteredtimeseries;
	double c, w, A, B, C, D, N, tmpdenom;
	int tt_left, tt_right;
	int dt;
	
	// define the convolution kernel
	hp_mask_size = sigma*3;
	
	hp_exp_array = mxCreateDoubleMatrix(1,(hp_mask_size*2+1),mxREAL);
	hp_exp= mxGetPr(hp_exp_array);
	
	hp_convkernel(hp_exp, hp_mask_size, sigma);
	
	
	// select the time series
	voxel_rawtimeseries_array = mxCreateDoubleMatrix(1,nt, mxREAL);
	voxel_rawtimeseries = mxGetPr(voxel_rawtimeseries_array);
	
	voxel_filteredtimeseries_array = mxCreateDoubleMatrix(1,nt, mxREAL);
	voxel_filteredtimeseries = mxGetPr(voxel_filteredtimeseries_array);
	
	for (v = 0; v < nv; v++)
	{
		//get a column of data
		for (t = 0; t < nt; t++)
		{
			voxel_rawtimeseries[t] = raw_data[v*nt + t];
		}
		
		//initialize done_c0 and c0
		done_c0 = 0;
		c0 = 0;
		
		//loop through the t
		for (t = 0; t < nt; t++)
		{
			//reset these variables
			A=0;
			B=0;
			C=0;
			D=0;
			N=0;
			
			//get the range of convolution for each t
			tt_left = get_max_val(t-hp_mask_size, 0);
			tt_right = get_min_val(t+hp_mask_size, nt-1);
			
			//loop through the convolution
			for(tt=tt_left; tt<=tt_right; tt++)
			{
				dt = tt-t;
				w = hp_exp[dt+hp_mask_size];
				A += w * dt;
				B += w * voxel_rawtimeseries[tt];
				C += w * dt * dt;
				D += w * dt * voxel_rawtimeseries[tt];
				N += w;
			}
			
			// calculate the temporary denominator for t
			tmpdenom=C*N-A*A;
			
			// check that its not zero
			if (tmpdenom != 0)
			{
				// if its not zero, divide c by this value
				c = (B*C-A*D) / tmpdenom;
				// and set done_c0 to 1
				if (done_c0 == 0)
				{
					c0=c;
					done_c0=1;
				}

				voxel_filteredtimeseries[t] = c0 + voxel_rawtimeseries[t] - c;
			}
			else {
				voxel_filteredtimeseries[t] = voxel_rawtimeseries[t];
			}
		} // end t loop
		
		
		for (t = 0; t < nt; t++)
		{
			filtered_data[v*nt+t] = voxel_filteredtimeseries[t];
		}
		
	}
}

void hp_convkernel(double *hp_exp, const int hp_mask_size, const int sigma)
{
	int i, t;
	
	for (i = 0; i <= (hp_mask_size*2+1); i++)
	{
		t = i - hp_mask_size;
		hp_exp[i] = exp( -0.5 * ((double)(t*t)) / (sigma * sigma) );
	}
}

double get_max_val(const int input1, const int input2)
{
	if (input2>input1)
	{
		return input2;
	}
	else {
		return input1;
	}
}


double get_min_val(const int input1, const int input2)
{
	if (input1>input2)
	{
		return input2;
	}
	else {
		return input1;
	}
}