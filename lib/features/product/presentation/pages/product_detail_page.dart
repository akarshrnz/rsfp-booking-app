import 'dart:ui';
import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dartz/dartz.dart' as p;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:innerspace_booking_app/core/constants.dart';
import 'package:innerspace_booking_app/core/app_constants.dart';
import 'package:innerspace_booking_app/core/app_image.dart';
import 'package:innerspace_booking_app/core/app_text_styles.dart';
import 'package:innerspace_booking_app/core/color_constant.dart';
import 'package:innerspace_booking_app/core/common_widgets/dotted_line.dart';
import 'package:innerspace_booking_app/core/common_widgets/gradient_button.dart';
import 'package:innerspace_booking_app/features/product/domain/entities/product.dart';
import 'package:innerspace_booking_app/features/product/presentation/bloc/product_bloc.dart';

class ProductDetailPage
    extends
        StatefulWidget {
  final String productId;
  const ProductDetailPage({
    super.key,
    required this.productId,
  });

  @override
  State<
    ProductDetailPage
  >
  createState() => _ProductDetailPageState();
}

class _ProductDetailPageState
    extends
        State<
          ProductDetailPage
        > {
  final PageController _pageController = PageController();
  Timer? _carouselTimer;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _startCarouselTimer();
  }

  @override
  void dispose() {
    _carouselTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  void _startCarouselTimer() {
    _carouselTimer = Timer.periodic(
      const Duration(
        seconds: 3,
      ),
      (
        _,
      ) {
        if (_pageController.hasClients) {
          _currentPage =
              (_currentPage +
                  1) %
              2; // Only 2 images
          _pageController.animateToPage(
            _currentPage,
            duration: const Duration(
              milliseconds: 500,
            ),
            curve: Curves.easeInOut,
          );
        }
      },
    );
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    return Scaffold(
      backgroundColor: cardBackground,
      body:
          BlocBuilder<
            ProductBloc,
            ProductState
          >(
            builder:
                (
                  context,
                  state,
                ) {
                  if (state
                      is ProductLoaded) {
                    final branch = state.products.firstWhere(
                      (
                        b,
                      ) =>
                          b.id ==
                          widget.productId,
                      orElse: () => throw Exception(
                        'Branch not found',
                      ),
                    );
                    return Stack(
                      children: [
                        _buildTopBanner(
                          branch,
                        ),
                        _buildMainContent(
                          branch,
                        ),
                        _buildBackButton(),
                        _buildBottomBar(
                          branch,
                        ),
                        _buildImageIndicator(
                          branch,
                        ),
                      ],
                    );
                  }
                  return _buildLoadingScreen();
                },
          ),
    );
  }

  /// Loading state
  Widget _buildLoadingScreen() => Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _customLoadingIndicator(),
        SizedBox(
          height: 20.h,
        ),
        Text(
          'Loading Branch Details...',
          style: AppTextStyles.cardTitle.copyWith(
            color: gradientOne,
          ),
        ),
      ],
    ),
  );

  Widget _customLoadingIndicator() => SizedBox(
    width: 60.w,
    height: 60.h,
    child: Stack(
      children: [
        Center(
          child: Container(
            width: 50.w,
            height: 50.h,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  gradientOne,
                  gradientTwo,
                ],
              ),
              shape: BoxShape.circle,
            ),
          ),
        ),
        Center(
          child: SizedBox(
            width: 40.w,
            height: 40.h,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              valueColor: AlwaysStoppedAnimation(
                Colors.white,
              ),
              backgroundColor: Colors.white.withOpacity(
                0.3,
              ),
            ),
          ),
        ),
      ],
    ),
  );

  /// Carousel banner
  Widget _buildTopBanner(
    dynamic branch,
  ) {
    final images = imageUrls;
    return Positioned.fill(
      top: 0,
      bottom:
          MediaQuery.of(
            context,
          ).size.height *
          0.6,
      child: PageView.builder(
        controller: _pageController,
        itemCount: images.length,
        onPageChanged:
            (
              index,
            ) => setState(
              () => _currentPage = index,
            ),
        itemBuilder:
            (
              _,
              index,
            ) => GestureDetector(
              onTap: () => _showFullScreenImage(
                images[index],
              ),
              child: CachedNetworkImage(
                imageUrl: images[index],
                fit: BoxFit.cover,
                placeholder:
                    (
                      _,
                      __,
                    ) => _imagePlaceholder(),
                errorWidget:
                    (
                      _,
                      __,
                      ___,
                    ) => _imageErrorPlaceholder(),
              ),
            ),
      ),
    );
  }

  Widget _imagePlaceholder() => Container(
    color: Colors.grey[200],
    child: Center(
      child: _customLoadingIndicator(),
    ),
  );
  Widget _imageErrorPlaceholder() => Container(
    color: Colors.grey[200],
    child: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.broken_image,
            size: 40.w,
            color: Colors.grey[400],
          ),
          SizedBox(
            height: 8.h,
          ),
          Text(
            'Failed to load image',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14.sp,
            ),
          ),
        ],
      ),
    ),
  );

  /// Image indicator dots
  Widget _buildImageIndicator(
    dynamic branch,
  ) {
    final images = imageUrls;
    return Positioned(
      top:
          MediaQuery.of(
                context,
              ).size.height *
              0.25 -
          30.h,
      left: 0,
      right: 0,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(
          images.length,
          (
            i,
          ) {
            return Container(
              width: 10.w,
              height: 10.h,
              margin: EdgeInsets.symmetric(
                horizontal: 4.w,
              ),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color:
                    _currentPage ==
                        i
                    ? gradientOne
                    : Colors.white.withOpacity(
                        0.5,
                      ),
                border: Border.all(
                  color:
                      _currentPage ==
                          i
                      ? Colors.transparent
                      : Colors.grey,
                  width: 1,
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  /// Fullscreen image
  void
  _showFullScreenImage(
    String url,
  ) => Navigator.push(
    context,
    MaterialPageRoute(
      builder:
          (
            _,
          ) => Scaffold(
            backgroundColor: Colors.black,
            body: Stack(
              children: [
                Center(
                  child: GestureDetector(
                    onTap: () => Navigator.pop(
                      context,
                    ),
                    child: Hero(
                      tag: url,
                      child: CachedNetworkImage(
                        imageUrl: url,
                        fit: BoxFit.contain,
                        placeholder:
                            (
                              _,
                              __,
                            ) => _imagePlaceholder(),
                        errorWidget:
                            (
                              _,
                              __,
                              ___,
                            ) => _imageErrorPlaceholder(),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 40.h,
                  right: 20.w,
                  child: IconButton(
                    icon: Icon(
                      Icons.close,
                      size: 28.w,
                      color: Colors.white,
                    ),
                    onPressed: () => Navigator.pop(
                      context,
                    ),
                  ),
                ),
              ],
            ),
          ),
    ),
  );

  /// Main scrollable content
  Widget
  _buildMainContent(
    dynamic branch,
  ) => Positioned.fill(
    top:
        MediaQuery.of(
          context,
        ).size.height *
        0.3,
    child: Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 20,
          ),
          child: _buildBranchInfoCard(
            branch,
          ),
        ),
        SizedBox(
          height: 20.h,
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: 22,
            ),
            child: Column(
              children: [
                _buildDescriptionSection(
                  branch,
                ),
                SizedBox(
                  height: 20.h,
                ),

                /// _buildAmenitiesSection(branch),
                SizedBox(
                  height: 20.h,
                ),
                //_buildOperatingHoursSection(branch),
                SizedBox(
                  height: 120.h,
                ),
              ],
            ),
          ),
        ),
      ],
    ),
  );

  /// Back button
  Widget _buildBackButton() => Positioned(
    top: 40.h,
    left: 16.w,
    child: GestureDetector(
      onTap: () => Navigator.pop(
        context,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(
          16.r,
        ),
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: 10,
            sigmaY: 10,
          ),
          child: Container(
            height: 35.h,
            width: 35.w,
            decoration: BoxDecoration(
              color: const Color(
                0xCCD6CDBE,
              ),
              borderRadius: BorderRadius.circular(
                16.r,
              ),
            ),
            child: Center(
              child: Icon(
                Icons.arrow_back_ios_new_rounded,
                size: 22,
                color: Colors.black,
              ),
            ),
          ),
        ),
      ),
    ),
  );

  /// Bottom booking bar
  Widget
  _buildBottomBar(
    Product branch,
  ) => Positioned(
    bottom: 20.h,
    left: 16.w,
    right: 16.w,
    child: Container(
      padding: EdgeInsets.symmetric(
        horizontal: 16.w,
        vertical: 12.h,
      ),
      decoration: BoxDecoration(
        color: cardBackground,
        borderRadius: BorderRadius.circular(
          16.r,
        ),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
            offset: Offset(
              0,
              3,
            ),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Limited stocks',
                style: AppTextStyles.cardSubText.copyWith(
                  fontSize: 12.sp,
                ),
              ),
              Text(
                '\₹20000',
                style: AppTextStyles.cardTitle.copyWith(
                  fontSize: 16.sp,
                  color: gradientOne,
                ),
              ),
            ],
          ),
          GradientButton(
            height: 48.h,
            width: 150.w,
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              colors: [
                gradientOne,
                gradientTwo,
              ],
            ),
            radius: 16.r,
            onTap: () {
              final user = FirebaseAuth.instance.currentUser;

              context
                  .read<
                    ProductBloc
                  >()
                  .add(
                    OrdersCreate(
                      dummyUserId,
                     // user!.uid,
                      widget.productId,
                    ),
                  );
              Fluttertoast.showToast(
                msg: "🎉 Product booked successfully!",
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.BOTTOM,
                backgroundColor: Colors.green,
                textColor: Colors.white,
                fontSize: 16.0,
              );
            },
            title: "Book Now",
          ),
        ],
      ),
    ),
  );

  /// Branch info card
  Widget
  _buildBranchInfoCard(
    dynamic branch,
  ) => Container(
    padding: EdgeInsets.all(
      16.w,
    ),
    decoration: BoxDecoration(
      color: cardBackground,
      borderRadius: BorderRadius.circular(
        16.r,
      ),
      boxShadow: const [
        BoxShadow(
          color: Colors.black12,
          blurRadius: 6,
          offset: Offset(
            0,
            3,
          ),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildBranchHeader(
          branch,
        ),
        SizedBox(
          height: 10.h,
        ),
        DottedLine(
          space: 5.w,
          color: gradientOne.withOpacity(
            .5,
          ),
        ),
        SizedBox(
          height: 10.h,
        ),
        _buildOfferCard(),
      ],
    ),
  );

  /// Branch header with name, city, location, rating
  Widget
  _buildBranchHeader(
    Product branch,
  ) => Row(
    children: [
      Container(
        width: 40.w,
        height: 40.h,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              gradientOne,
              gradientTwo,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          shape: BoxShape.circle,
        ),
        child: Center(
          child: Text(
            branch.name.substring(
              0,
              1,
            ),
            style: TextStyle(
              color: Colors.white,
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
      SizedBox(
        width: 12.w,
      ),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              branch.name,
              style: AppTextStyles.cardTitle,
            ),
            SizedBox(
              height: 4.h,
            ),
            Row(
              children: [
                Image.asset(
                  AppImage.shopColor,
                  height: 22,
                  width: 22,
                ),
                SizedBox(
                  width: 4.w,
                ),
                 Text("Samsung India", style: AppTextStyles.cardSubText),
                SizedBox(
                  width: 10.w,
                ),
               
                SizedBox(
                  width: 10.w,
                ),
                Image.asset(
                  AppImage.star,
                  height: 22,
                  width: 22,
                ),
                Text(
                  ' 4.5',
                  style: AppTextStyles.cardSubText,
                ),
              ],
            ),
          ],
        ),
      ),
    ],
  );

  Widget _buildOfferCard() => Container(
    width: double.infinity,
    padding: EdgeInsets.symmetric(
      horizontal: 12.w,
      vertical: 10.h,
    ),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(
        16.r,
      ),
      color: cardBackground,
      border: Border.all(
        width: 2.w,
        color: const Color(
          0xFFF0F0F0,
        ),
      ),
    ),
    child: Row(
      children: [
        Image.asset(
          AppImage.offer,
          width: 32.w,
          height: 30.h,
        ),
        SizedBox(
          width: 10.w,
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Use code FIRST',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14.sp,
                ),
              ),
              Text(
                'Get 10% off on your first booking',
                style: AppTextStyles.cardSubText,
              ),
            ],
          ),
        ),
      ],
    ),
  );

  /// Description section
  Widget
  _buildDescriptionSection(
    dynamic data,
  ) => _buildSection(
    icon: Icons.description,
    title: 'Description',
    content: des,
  );

  /// Generic section builder
  Widget
  _buildSection({
    required IconData icon,
    required String title,
    String? content,
    Widget? contentWidget,
  }) => Container(
    width: double.infinity,
    padding: EdgeInsets.all(
      16.w,
    ),
    decoration: BoxDecoration(
      color: cardBackground,
      borderRadius: BorderRadius.circular(
        16.r,
      ),
      boxShadow: const [
        BoxShadow(
          color: Colors.black12,
          blurRadius: 6,
          offset: Offset(
            0,
            3,
          ),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              icon,
              size: 20.w,
              color: gradientOne,
            ),
            SizedBox(
              width: 8.w,
            ),
            Text(
              title,
              style: AppTextStyles.cardTitle.copyWith(
                fontSize: 16.sp,
              ),
            ),
          ],
        ),
        SizedBox(
          height: 8.h,
        ),
        contentWidget ??
            Text(
              content ??
                  '',
              style: AppTextStyles.cardSubText,
            ),
      ],
    ),
  );
}
