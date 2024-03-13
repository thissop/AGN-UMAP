from astropy.io import fits 
import pandas as pd
import numpy as np
from astropy.table import Table
import os 
from sklearn.manifold import TSNE
from sklearn.decomposition import PCA
from matplotlib import pyplot as plt

data = []

# ['ra', 'dec', 'plateid', 'MJD', 'fiberid', 'redshift', 'SNR_SPEC', 'SN_ratio_conti', 'Fe_uv_norm', 'Fe_uv_norm_err', 'Fe_uv_FWHM', 'Fe_uv_FWHM_err', 'Fe_uv_shift', 'Fe_uv_shift_err', 'Fe_op_norm', 'Fe_op_norm_err', 'Fe_op_FWHM', 'Fe_op_FWHM_err', 'Fe_op_shift', 'Fe_op_shift_err', 'PL_norm', 'PL_norm_err', 'PL_slope', 'PL_slope_err', 'BalmerC_norm', 'BalmerC_norm_err', 'BalmerS_FWHM', 'BalmerS_FWHM_err', 'BalmerS_norm', 'BalmerS_norm_err', 'POLY_a', 'POLY_a_err', 'POLY_b', 'POLY_b_err', 'POLY_c', 'POLY_c_err', 'L1350', 'L1350_err', 'L3000', 'L3000_err', 'L5100', 'L5100_err', 'LINE_NPIX_CIV', 'CIV_line_status', 'CIV_line_min_chi2', 'LINE_MED_SN_CIV', 'LINE_NPIX_CIII', 'CIII_line_status', 'CIII_line_min_chi2', 'CIII_line_red_chi2', 'CIII_niter', 'CIII_ndof', 'LINE_MED_SN_CIII', 'LINE_NPIX_MgII', 'MgII_line_status', 'MgII_line_min_chi2', 'MgII_line_red_chi2', 'MgII_niter', 'MgII_ndof', 'LINE_MED_SN_MgII', 'CIV_whole_br_fwhm', 'CIV_whole_br_fwhm_err', 'CIV_whole_br_sigma', 'CIV_whole_br_sigma_err', 'CIV_whole_br_ew', 'CIV_whole_br_ew_err', 'CIV_whole_br_peak', 'CIV_whole_br_peak_err', 'CIV_whole_br_area', 'CIV_whole_br_area_err', 'CIV_whole_fwhm', 'CIV_whole_sigma', 'CIV_whole_ew', 'CIV_whole_peak', 'CIV_whole_area', 'CIII_whole_br_fwhm', 'CIII_whole_br_fwhm_err', 'CIII_whole_br_sigma', 'CIII_whole_br_sigma_err', 'CIII_whole_br_ew', 'CIII_whole_br_ew_err', 'CIII_whole_br_peak', 'CIII_whole_br_peak_err', 'CIII_whole_br_area', 'CIII_whole_br_area_err', 'MgII_whole_br_fwhm', 'MgII_whole_br_fwhm_err', 'MgII_whole_br_sigma', 'MgII_whole_br_sigma_err', 'MgII_whole_br_ew', 'MgII_whole_br_ew_err', 'MgII_whole_br_peak', 'MgII_whole_br_peak_err', 'MgII_whole_br_area', 'MgII_whole_br_area_err', 'MgII_na_fwhm', 'MgII_na_fwhm_err', 'MgII_na_sigma', 'MgII_na_sigma_err', 'MgII_na_ew', 'MgII_na_ew_err', 'MgII_na_peak', 'MgII_na_peak_err', 'MgII_na_area', 'MgII_na_area_err']
properties = ['Fe_uv_norm', 'Fe_uv_norm_err', 'Fe_uv_FWHM', 'Fe_uv_FWHM_err', 'Fe_uv_shift', 'Fe_uv_shift_err', 'Fe_op_norm', 'Fe_op_norm_err', 'Fe_op_FWHM', 'Fe_op_FWHM_err', 'Fe_op_shift', 'Fe_op_shift_err', 'PL_norm', 'PL_norm_err', 'PL_slope', 'PL_slope_err', 'BalmerC_norm', 'BalmerC_norm_err', 'BalmerS_FWHM', 'BalmerS_FWHM_err', 'BalmerS_norm', 'BalmerS_norm_err', 'POLY_a', 'POLY_a_err', 'POLY_b', 'POLY_b_err', 'POLY_c', 'POLY_c_err', 'L1350', 'L1350_err', 'L3000', 'L3000_err', 'L5100', 'L5100_err', 'LINE_NPIX_Lya', 'Lya_line_status', 'Lya_line_min_chi2', 'Lya_line_red_chi2', 'Lya_niter', 'Lya_ndof', 'LINE_MED_SN_Lya', 'LINE_NPIX_CIV', 'CIV_line_status', 'CIV_line_min_chi2', 'CIV_line_red_chi2', 'CIV_niter', 'CIV_ndof', 'LINE_MED_SN_CIV', 'LINE_NPIX_CIII', 'CIII_line_status', 'CIII_line_min_chi2', 'CIII_line_red_chi2', 'CIII_niter', 'CIII_ndof', 'LINE_MED_SN_CIII', 'LINE_NPIX_MgII', 'MgII_line_status', 'MgII_line_min_chi2', 'MgII_line_red_chi2', 'MgII_niter', 'MgII_ndof', 'LINE_MED_SN_MgII', 'Lya_whole_br_fwhm', 'Lya_whole_br_fwhm_err', 'Lya_whole_br_sigma', 'Lya_whole_br_sigma_err', 'Lya_whole_br_ew', 'Lya_whole_br_ew_err', 'Lya_whole_br_peak', 'Lya_whole_br_peak_err', 'Lya_whole_br_area', 'Lya_whole_br_area_err', 'CIV_whole_br_fwhm', 'CIV_whole_br_fwhm_err', 'CIV_whole_br_sigma', 'CIV_whole_br_sigma_err', 'CIV_whole_br_ew', 'CIV_whole_br_ew_err', 'CIV_whole_br_peak', 'CIV_whole_br_peak_err', 'CIV_whole_br_area', 'CIV_whole_br_area_err', 'CIV_whole_fwhm', 'CIV_whole_sigma', 'CIV_whole_ew', 'CIV_whole_peak', 'CIV_whole_area', 'CIII_whole_br_fwhm', 'CIII_whole_br_fwhm_err', 'CIII_whole_br_sigma', 'CIII_whole_br_sigma_err', 'CIII_whole_br_ew', 'CIII_whole_br_ew_err', 'CIII_whole_br_peak', 'CIII_whole_br_peak_err', 'CIII_whole_br_area', 'CIII_whole_br_area_err', 'MgII_whole_br_fwhm', 'MgII_whole_br_fwhm_err', 'MgII_whole_br_sigma', 'MgII_whole_br_sigma_err', 'MgII_whole_br_ew', 'MgII_whole_br_ew_err', 'MgII_whole_br_peak', 'MgII_whole_br_peak_err', 'MgII_whole_br_area', 'MgII_whole_br_area_err', 'NV1240_fwhm', 'NV1240_fwhm_err', 'NV1240_sigma', 'NV1240_sigma_err', 'NV1240_ew', 'NV1240_ew_err', 'NV1240_peak', 'NV1240_peak_err', 'NV1240_area', 'NV1240_area_err', 'MgII_na_fwhm', 'MgII_na_fwhm_err', 'MgII_na_sigma', 'MgII_na_sigma_err', 'MgII_na_ew', 'MgII_na_ew_err', 'MgII_na_peak', 'MgII_na_peak_err', 'MgII_na_area', 'MgII_na_area_err']

fits_dir = '/Users/yaroslav/Documents/2. work/Research/GitHub/AGN-UMAP/code/monthly/nov2023/wk1/qsofitmore/output/'
for filename in os.listdir(fits_dir):
    if 'spSpec' in filename and '.fits' in filename:
        df = Table.read(os.path.join(fits_dir, filename), format='fits').to_pandas()
        labels = list(df)
        row = []
        for i in properties: 
            if i in labels: 
                row.append(df[i][0])
            else: 
                row.append(0)

        data.append(row)

data = np.array(data)

pca = PCA()
#pca.fit(data)

print(data)

result = TSNE(n_components=2, random_state=0).fit_transform(data)

x = result[:, 0]
y = result[:, 1]

plt.scatter(x, y)
plt.show()