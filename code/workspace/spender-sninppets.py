    def loss(self, y, w, instrument=None, z=None, s=None, normalize=False, individual=False):
        """Weighted MSE loss

        Parameter
        --------
        y: `torch.tensor`, shape (N, L)
            Batch of observed spectra
        w: `torch.tensor`, shape (N, L)
            Batch of weights for observed spectra
        instrument: :class:`spender.Instrument`
            Instrument to generate spectrum for
        z: `torch.tensor`, shape (N, 1)
            Redshifts for each spectrum. When given, `aux` is ignored.
        s: `torch.tensor`, shape (N, S)
            (optional) Batch of latents. When given, encoding is omitted and these
            latents are used instead.
        normalize: bool
            (optional) Whether to normalize the reconstruction match the amplitude of the observed spectrum.
            If this is set to False, it requires that the spectra have been flux-normalized.
        individual: bool
            Whether the loss is computed for each spectrum individually or aggregated

        Returns
        -------
        float or `torch.tensor`, shape (N,) of weighted MSE loss
        """
        y_ = self.forward(y, instrument=instrument, z=z, s=s, normalize=normalize)
        return self._loss(y, w, y_, individual=individual)

    def _loss(self, y, w, y_, individual=False):
        # loss = total squared deviation in units of variance
        # if the model is identical to observed spectrum (up to the noise),
        # then loss per object = D (number of non-zero bins)

        # to make it to order unity for comparing losses, divide out L (number of bins)
        # instead of D, so that spectra with more valid bins have larger impact
        loss_ind = torch.sum(0.5 * w * (y - y_).pow(2), dim=1) / y.shape[1]

        if individual:
            return loss_ind

        return torch.sum(loss_ind)