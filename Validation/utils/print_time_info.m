function print_time_info(t_ref, t_test)
%PRINT_TIME_INFO Display timing summary.

fprintf('\n--- TIME INFORMATION ---\n');

fprintf('Reference duration: %.2f s\n', ...
        t_ref(end)-t_ref(1));

fprintf('Test duration: %.2f s\n', ...
        t_test(end)-t_test(1));



end