/*
Copyright (c) 2021, azad prajapat
https://github.com/azadprajapat/opencv_awesome/blob/master/android/src/main/jni/native_opencv.cpp

Copyright (c) 2022, 小島 伊織 / Iori Kojima
*/

//複数の画像をパノラマ画像にstitchする
#include <opencv2/opencv.hpp>
#include <opencv2/stitching.hpp>
#include <opencv2/imgproc.hpp>

using namespace cv;
using namespace std;

struct tokens : ctype<char>
{
    tokens() : std::ctype<char>(get_table()) {}

    static std::ctype_base::mask const *get_table()
    {
        typedef std::ctype<char> cctype;
        static const cctype::mask *const_rc = cctype::classic_table();

        static cctype::mask rc[cctype::table_size];
        std::memcpy(rc, const_rc, cctype::table_size * sizeof(cctype::mask));

        rc[','] = ctype_base::space;
        rc[' '] = ctype_base::space;
        return &rc[0];
    }
};
vector<string> getpathlist(string path_string)
{
    string sub_string = path_string.substr(1, path_string.length() - 2);
    stringstream ss(sub_string);
    ss.imbue(locale(locale(), new tokens()));
    istream_iterator<std::string> begin(ss);
    istream_iterator<std::string> end;
    vector<std::string> pathlist(begin, end);
    return pathlist;
}

Mat process_stitching(vector<Mat> imgVec,bool verticalWaveCorrection)
{
    Mat result = Mat();
    Stitcher::Mode mode = Stitcher::PANORAMA;
    Ptr<Stitcher> stitcher = Stitcher::create(mode);
    stitcher->setRegistrationResol(0.5);
    stitcher->setSeamEstimationResol(0.1);
    stitcher->setCompositingResol(1);
    stitcher->setPanoConfidenceThresh(1);
    stitcher->setWaveCorrection(true);
    if (verticalWaveCorrection) {
        stitcher->setWaveCorrectKind(detail::WAVE_CORRECT_VERT);
    }
    else {
        stitcher->setWaveCorrectKind(detail::WAVE_CORRECT_HORIZ);
    }

    Stitcher::Status status = stitcher->stitch(imgVec, result);
    if (status != Stitcher::OK)
    {
        hconcat(imgVec, result);
        printf("Stitching error: %d\n", status);
    }
    else
    {
        printf("Stitching success\n");
    }

    cvtColor(result, result, COLOR_RGB2BGR);
    return result;
}

Mat process_yanyana(vector<Mat> imgVec)
{
    Mat result = Mat();
    hconcat(imgVec, result);
    cvtColor(result, result, COLOR_RGB2BGR);
    return result;
}

vector<Mat> convert_to_matlist(vector<string> img_list, bool isvertical)
{
    vector<Mat> imgVec;
    for (auto k = img_list.begin(); k != img_list.end(); ++k)
    {
        String path = *k;
        Mat input = imread(path);
        Mat newimage;
        // Convert to a 3 channel Mat to use with Stitcher module
        cvtColor(input, newimage, COLOR_BGR2RGB, 3);
        // Reduce the resolution for fast computation
        if (isvertical){
            rotate(newimage, newimage, ROTATE_90_COUNTERCLOCKWISE);
        }
        imgVec.push_back(newimage);
    }
    return imgVec;
}

void stitch(char *inputImagePath, char *outputImagePath,int flag)
{
    string input_path_string = inputImagePath;
    vector<string> image_vector_list = getpathlist(input_path_string);
    vector<Mat> mat_list;
    bool check = (flag == 1);
    Mat result;
    if(flag == 3){
        mat_list = convert_to_matlist(image_vector_list, false);
        result = process_yanyana(mat_list);
    }else{
        mat_list = convert_to_matlist(image_vector_list, check);
        result = process_stitching(mat_list,check);
    }

    Mat cropped_image;
    result(Rect(0, 0, result.cols, result.rows)).copyTo(cropped_image);

    imwrite(outputImagePath, cropped_image);
    /*
        cv::Mat in = cv::imread(outputImagePath);
        std::vector<cv::Point> nonBlackList;
        nonBlackList.reserve(in.rows*in.cols);
        for(int j=0; j<in.rows; ++j)
            for(int i=0; i<in.cols; ++i)
            {
                if(in.at<cv::Vec3b>(j,i) != cv::Vec3b(0,0,0))
                {
                    nonBlackList.push_back(cv::Point(i,j));
                }
            }

        cv::Rect bb = cv::boundingRect(nonBlackList);
        cv::imwrite(outputImagePath, in(bb));
    */

  
}
