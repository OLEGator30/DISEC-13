function SkewEstimation(imgName, fileName)

img = ~imread(imgName);
res = houghMethod(img);

file = fopen(fileName, 'w');
fprintf(file, '%.2f', res);
fclose(file);

end

function sr = dilateMethod(img)

labImg = logical(imdilate(img, strel('disk', 4))); % TODO: norm

% figure
% imshow(label2rgb(labImg , 'hsv', 'k', 'shuffle'))

stat = regionprops(labImg, ...
                   'Eccentricity', ...
                   'Orientation');

ecc = [stat.Eccentricity];
idx = (ecc < 0.99) & (ecc > 0.8);

% procImg = ismember(labImg, idx);
% figure
% imshow(label2rgb(procImg , 'hsv', 'k', 'shuffle'))

orient = [stat.Orientation];
alpha = orient(idx);
idx = abs(alpha) > 45;
alpha(idx) = -sign(alpha(idx)) * 90 + alpha(idx);
alpha = alpha((alpha > -15) & (alpha < 15));
sr = mean(alpha);

end

function sr = houghMethod(img)

edgeImg = edge(img, 'canny');
% figure
% imshow(edgeImg);
% hold on

[H, theta, rho] = hough(edgeImg,
                        'Theta', [-90:0.5:-75 -15:0.5:15 75:0.5:89.5]);
P = houghpeaks(H, 5, 'threshold', ceil(0.3 * max(H(:))));
lines = houghlines(edgeImg, theta, rho, P, 'FillGap', 20, 'MinLength', 95);

if ~isempty(fieldnames(lines))
    alpha = zeros(length(lines), 1);
    for k = 1:length(lines)
        xy = [lines(k).point1 ; lines(k).point2];
        alpha(k) = atand((xy(2) - xy(1)) / (xy(4) - xy(3)));
%         plot(xy(:,1), xy(:,2), 'LineWidth', 2, 'Color', 'green');
    end
    idx = abs(alpha) > 45;
    alpha(idx) = -sign(alpha(idx)) * 90 + alpha(idx);
    alpha = alpha((alpha > -15) & (alpha < 15));
    [~, ang] = max(hist(alpha, -15:15));
    alpha = alpha((alpha > ang - 17.5) & (alpha < ang - 14.5));
    sr = mean(alpha);
else
    sr = dilateMethod(img);
end

end

