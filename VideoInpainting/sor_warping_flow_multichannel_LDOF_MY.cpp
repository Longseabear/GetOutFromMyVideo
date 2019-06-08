// // [du,dv]=sor_warping_flow(ix,iy,iz, ixx, ixy, iyy, ixz,...
// iyz,psi_data, psi_smooth_east, psi_smooth_south, du, dv,u,v,alpha,gamma,sor_iter,w)

# include "mex.h"
# include "math.h"

#define at_r(ptr, y, x, c)  ( ((y)<0 || (y)>=raws || (x)<0 || (x)>=cols) ? 0.0 : (ptr)[(y) + ((x) + (c)*cols)*raws] )
#define lat_r(ptr, y, x, c) ((ptr)[(y) + ((x) + (c)*cols)*raws])


void sor(double* ix_ix, double* ix_iy, double* ix_iz, double* psi_data, double* psi_smooth_east,
        double* psi_smooth_south,
        double* du, double* dv, double* u, double* v, double alpha,
        double sor_iter, int p, int q, int nchannels, double w, double* iy_iy,double* iy_iz) {
    int iter=0;
    int i, j, k, n;
    double psi_n, psi_s, psi_w, psi_e,
            u_n, u_s, u_w, u_e,
            v_n, v_s, v_w, v_e,
            du_n, du_s, du_w, du_e,
            dv_n, dv_s, dv_w, dv_e;
     n=p*q;

    double *B_coef_u = (double*)mxCalloc(n, sizeof(double));
    double *B_const_u = (double*)mxCalloc(n, sizeof(double));
    double *B_coef_v = (double*)mxCalloc(n, sizeof(double));
    double *B_const_v = (double*)mxCalloc(n, sizeof(double));
    double *Aiipart_u = (double*)mxCalloc(n, sizeof(double));
    double *Aiipart_v = (double*)mxCalloc(n, sizeof(double));

    for (i=0; i<n; i++) {
        B_coef_u[i]=0.0;
        B_const_u[i]=0.0;
        B_coef_v[i]=0.0;
        B_const_v[i]=0.0;
        Aiipart_u[i]=0.0;
        Aiipart_v[i]=0.0;
        for (k=0; k<nchannels; k++) {
            j=k*n+i;
            B_coef_u[i]+=psi_data[j]*ix_iy[j];
            B_const_u[i]+=psi_data[j]*ix_iz[j];
            B_coef_v[i]+=psi_data[j]*ix_iy[j];
            B_const_v[i]+=psi_data[j]*iy_iz[j];
            Aiipart_u[i]+=psi_data[j]*ix_ix[j];
            Aiipart_v[i]+=psi_data[j]*iy_iy[j];
        }
    }
        
    for (iter=0; iter<sor_iter; iter++) {
        
        for (i=0; i<n; i++) {
            
            psi_n=((i%p==0)?0.0:psi_smooth_south[i-1]);
            psi_s=((i%p==p-1)?0.0:psi_smooth_south[i]);
            psi_w=((i<p)?0.0:psi_smooth_east[i-p]);
            psi_e=((i>=(q-1)*p)?0.0:psi_smooth_east[i]);
            
            u_n=((i%p==0)?0.0:u[i-1]);
            u_s=((i%p==p-1)?0.0:u[i+1]);
            u_w=((i<p)?0.0:u[i-p]);
            u_e=((i>=(q-1)*p)?0.0:u[i+p]);
            
            v_n=((i%p==0)?0.0:v[i-1]);
            v_s=((i%p==p-1)?0.0:v[i+1]);
            v_w=((i<p)?0.0:v[i-p]);
            v_e=((i>=(q-1)*p)?0.0:v[i+p]);
            
            du_n=((i%p==0)?0.0:du[i-1]);
            du_s=((i%p==p-1)?0.0:du[i+1]);
            du_w=((i<p)?0.0:du[i-p]);
            du_e=((i>=(q-1)*p)?0.0:du[i+p]);
            
            dv_n=((i%p==0)?0.0:dv[i-1]);
            dv_s=((i%p==p-1)?0.0:dv[i+1]);
            dv_w=((i<p)?0.0:dv[i-p]);
            dv_e=((i>=(q-1)*p)?0.0:dv[i+p]);
            
            
            
            
            du[i]=(1-w)*du[i]+
                    (w*(psi_n*(u_n+du_n)+
                    psi_e*(u_e+du_e)+
                    psi_w*(u_w+du_w)+
                    psi_s*(u_s+du_s)-
                    (psi_n+psi_e+psi_w+psi_s)*u[i])-
                    (w/alpha)*(B_coef_u[i]*dv[i]+B_const_u[i]))
                    /(psi_n+psi_e+psi_w+psi_s+
                    (1/alpha)*Aiipart_u[i]);
            
            
            dv[i]=(1-w)*dv[i]+
                    (w*(psi_n*(v_n+dv_n)+
                    psi_e*(v_e+dv_e)+
                    psi_w*(v_w+dv_w)+
                    psi_s*(v_s+dv_s)-
                    (psi_n+psi_e+psi_w+psi_s)*v[i])-
                    (w/alpha)*(B_coef_v[i]*du[i]+B_const_v[i]))
                    /(psi_n+psi_e+psi_w+psi_s+
                    (1/alpha)*Aiipart_v[i]);
        }
    }
    
    mxFree(B_coef_u);
    mxFree(B_const_u);
    mxFree(B_coef_v);
    mxFree(B_const_v);
    mxFree(Aiipart_u);
    mxFree(Aiipart_v);
    return;
}



void mexFunction(int nlhs, mxArray *plhs[], int nrhs,
        const mxArray *prhs[]) {
    /* declare variables */
    double *ix, *iy, *iz, *psi_data, *psi_smooth_east,
            *psi_smooth_south, *du, *dv, *u, *v, *dum;
    double *dims;
    double alpha, sor_iter, w;
    int p, q, nchannels, i;
    double *wp_ix, *wp_iy;

    mwSize elements;
//     if (nrhs < 18) {
// //         mexerrmsgtxt("not enough input arguments!!");
// //     }
    ix=mxGetPr(prhs[0]);
    elements=mxGetNumberOfElements(prhs[0]);
    //mexPrintf("\t\t\t  NumElems=%d \n", elements);
    iy=mxGetPr(prhs[1]);
    elements=mxGetNumberOfElements(prhs[1]);
    //mexPrintf("\t\t\t  NumElems=%d \n", elements);
    iz=mxGetPr(prhs[2]);
    psi_data=mxGetPr(prhs[3]);
    psi_smooth_east=mxGetPr(prhs[4]);
    psi_smooth_south=mxGetPr(prhs[5]);
    du=mxGetPr(prhs[6]);
    dv=mxGetPr(prhs[7]);
    u=mxGetPr(prhs[8]);
    v=mxGetPr(prhs[9]);
    p=mxGetScalar(prhs[10]);
    q=mxGetScalar(prhs[11]);
    nchannels=mxGetScalar(prhs[12]);
    dum=mxGetPr(prhs[13]);
    alpha=dum[0];
    dum=mxGetPr(prhs[14]);
    sor_iter=dum[0];
    dum=mxGetPr(prhs[15]);
    w=dum[0];
    wp_ix=mxGetPr(prhs[16]);
    wp_iy=mxGetPr(prhs[17]);
    
    //  , double* v_descr, double * ro, double psi_descr
//    mexPrintf("\t\t\t  p=%d, q=%d, nchannels=%dNumEl=%d\n", p, q, nchannels, p*q*nchannels);
    

    sor(ix, iy, iz, psi_data, psi_smooth_east, psi_smooth_south,
            du, dv, u, v, alpha, sor_iter, p, q, nchannels, w, wp_ix, wp_iy);
   
    return;
}
