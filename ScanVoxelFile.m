%r: radius of searchlight, in voxels
%V: volume of searchlight r=10 4169 r=3 123 r=2 33
function ScanVoxelFile(fileName, saveName, threshold, r, V)
 
F=spm_vol(fileName);
idx=spm_read_vols(F);

tIdx_sum=[];
h = waitbar(0, 'Calculating...');  % 创建进度条
totalIterations = length(col); % 计算总迭代次数
currentIteration = 0;  % 当前迭代次数

% 优化后的代码
for n = 1:length(col);
    i=col(n);
    j=row(n);
    k=z(n);
    % 更新迭代次数
    currentIteration = currentIteration + 1;
            
    % 更新进度条
    waitbar(currentIteration / totalIterations, h, sprintf('Calculating... %d%%', round(currentIteration / totalIterations * 100)));
            
            if idx(i, j, k) <= 0
                continue;
            end
            
            tIdx = [];
            for i0 = -r : r
                for j0 = -r : r
                    for k0 = -r : r
                        i_temp = i + i0;
                        j_temp = j + j0;
                        k_temp = k + k0;
                        
                        if (i_temp < 1 || i_temp > dim(1) || j_temp < 1 || j_temp > dim(2) || k_temp < 1 || k_temp > dim(3))
                            continue;
                        end
                        
                        if (i0 * i0 + j0 * j0 + k0 * k0 <= r * r && idx(i_temp, j_temp, k_temp) > threshold)
                            tIdx(end + 1) = idx(i_temp, j_temp, k_temp);
                            
                            if (length(tIdx) == V)
                                tIdx_total = [length(tIdx) i j k sum(tIdx)];
                                tIdx_sum = [tIdx_sum; tIdx_total];
                                break;  % 当达到 V 时，退出内部循环
                            end
                        end
                    end
                    
                    if (length(tIdx) == V)
                        break;  % 当达到 V 时，退出内部循环
                    end
                end
                
                if (length(tIdx) == V)
                    break;  % 当达到 V 时，退出内部循环
                end
            end
        end
    end
end
 
close(h);  % 关闭进度条
newnameGM=tIdx_sum;
save(saveName, 'newnameGM');