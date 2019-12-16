function [target_loc_pred] = reconstructSignalUsingFreqs(target_pred_days, amplitude, freq_domain, phase, num_freqs_to_use)

[max_amp, argmax_freq] = maxk(amplitude, num_freqs_to_use);

target_loc_pred = zeros(1, length(target_pred_days));
for ii_pred = 1:length(target_pred_days)
    x_pred = target_pred_days(ii_pred);

    pred = 0;
    for idx_freq = 1:num_freqs_to_use
        a = max_amp(idx_freq);
        f = freq_domain(argmax_freq(idx_freq));
        phi = phase(argmax_freq(idx_freq));
        pred = pred + a * cos(2*pi*f*x_pred + phi); % NOTE: using cos, not sin (ref: http://bit.ly/2MdJxHF)
    end

    target_loc_pred(ii_pred) = pred;
end

end

