import 'dart:convert';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:foodpanda_app/Models/restaurant_model.dart';
import 'package:foodpanda_app/Providers/cart_provider.dart';
import 'package:foodpanda_app/Providers/profile_provider.dart';
import 'package:foodpanda_app/Providers/favorite_provider.dart';
import 'package:foodpanda_app/Screens/restaurant_detail_screen.dart';
import 'package:foodpanda_app/Screens/favorites_screen.dart';
import 'package:foodpanda_app/Screens/orders_screen.dart';
import 'package:foodpanda_app/Screens/profile_screen.dart';
import 'package:foodpanda_app/utils/app_theme.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<Restaurant> _allRestaurants = [
    Restaurant(
      id: '1',
      name: 'McDonald\'s',
      imagePath: 'assets/images/mcdonalds.png',
      category: 'Fast Food',
      rating: 4.3,
      deliveryTime: '20-30 min',
      priceRange: 'R\$',
    ),
    Restaurant(
      id: '2',
      name: 'Burger King',
      imagePath: 'assets/images/burgerking.png',
      category: 'Fast Food',
      rating: 4.2,
      deliveryTime: '25-35 min',
      priceRange: 'R\$',
    ),
    Restaurant(
      id: '3',
      name: 'KFC',
      imagePath: 'assets/images/kfc.png',
      category: 'Fast Food',
      rating: 4.1,
      deliveryTime: '30-40 min',
      priceRange: 'R\$',
    ),
    Restaurant(
      id: '4',
      name: 'Domino\'s',
      imagePath: 'assets/images/dominos.png',
      category: 'Pizza',
      rating: 4.4,
      deliveryTime: '20-30 min',
      priceRange: 'R\$',
    ),
    Restaurant(
      id: '5',
      name: 'Subway',
      imagePath: 'assets/images/subway.png',
      category: 'Healthy',
      rating: 4.0,
      deliveryTime: '15-25 min',
      priceRange: 'R\$',
    ),
  ];

  List<Restaurant> _filteredRestaurants = [];
  final TextEditingController _searchController = TextEditingController();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  int _currentIndex = 0;
  final ScrollController _scrollController = ScrollController();
  String _selectedAddress = 'Home • 123 Street';
  String _selectedCategory = 'All';

  @override
  void initState() {
    super.initState();
    _filteredRestaurants = _allRestaurants;
    _searchController.addListener(_filterRestaurants);
  }

  void _filterRestaurants() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredRestaurants = _allRestaurants.where((restaurant) {
        final matchesQuery = query.isEmpty ||
            restaurant.name.toLowerCase().contains(query) ||
            restaurant.category.toLowerCase().contains(query);
            
        bool matchesCategory = true;
        if (_selectedCategory != 'All') {
          if (_selectedCategory == 'Burgers') {
            matchesCategory = restaurant.name.contains('Burger') || restaurant.name.contains('McDonald');
          } else if (_selectedCategory == 'Chicken') {
            matchesCategory = restaurant.name.contains('KFC');
          } else {
            matchesCategory = restaurant.category == _selectedCategory;
          }
        }
        
        return matchesQuery && matchesCategory;
      }).toList();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // Define _buildDrawer inside the state class
  Widget _buildDrawer() {
    return Drawer(
      width: 280,
      child: Column(
        children: [
          Consumer<ProfileProvider>(
            builder: (_, profile, __) => InkWell(
              onTap: () {
                Navigator.pop(context);
                setState(() {
                  _currentIndex = 3;
                });
              },
              child: UserAccountsDrawerHeader(
                decoration: BoxDecoration(color: AppTheme.primaryColor),
                margin: EdgeInsets.zero,
                accountName: Text(
                  profile.name,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                accountEmail: Text(profile.email),
                currentAccountPicture: profile.hasProfileImage
                    ? CircleAvatar(
                        backgroundImage: MemoryImage(base64Decode(profile.profileImageBase64!)),
                      )
                    : CircleAvatar(
                        backgroundColor: Colors.white,
                        child: Icon(Icons.person, color: AppTheme.primaryColor),
                      ),
              ),
            ),
          ),
          ListTile(
            leading: Icon(Icons.home),
            title: Text('Home'),
            onTap: () => Navigator.pop(context),
          ),
          ListTile(
            leading: Icon(Icons.favorite),
            title: Text('Favorites'),
            onTap: () {
              Navigator.pop(context); // Close Drawer
              setState(() {
                _currentIndex = 1;
              });
            },
          ),
          ListTile(
            leading: Icon(Icons.history),
            title: Text('Orders'),
            onTap: () {
              Navigator.pop(context); // Close Drawer
              setState(() {
                _currentIndex = 2;
              });
            },
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.settings),
            title: Text('Settings'),
            onTap: () {},
          ),
          ListTile(
            leading: Icon(Icons.help),
            title: Text('Help'),
            onTap: () {},
          ),
        ],
      ),
    );
  }

  void _showAddressSelector() {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        final addresses = [
          'Home • 123 Street',
          'Office • Downtown',
          'Hostel • Block A',
        ];
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Select delivery address',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              ...addresses.map(
                (address) => ListTile(
                  leading: Icon(
                    address.startsWith('Home')
                        ? Icons.home
                        : Icons.location_on_outlined,
                    color: AppTheme.primaryColor,
                  ),
                  title: Text(address),
                  onTap: () {
                    setState(() {
                      _selectedAddress = address;
                    });
                    Navigator.pop(context);
                  },
                ),
              ),
              SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: _buildDrawer(),
      body: IndexedStack(
        index: _currentIndex,
        children: [
          _buildHomeContent(),
          const FavoritesScreen(),
          const OrdersScreen(),
          const ProfileScreen(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: AppTheme.primaryColor,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
          if (index == 0) {
            _scrollController.animateTo(
              0,
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeOut,
            );
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite_border),
            activeIcon: Icon(Icons.favorite),
            label: 'Favorites',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long),
            label: 'Orders',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  Widget _buildHomeContent() {
    return CustomScrollView(
      controller: _scrollController,
      slivers: [
        // STICKY APP BAR
        SliverAppBar(
          pinned: true,
          floating: false,
          expandedHeight: 115.0,
          backgroundColor: AppTheme.primaryColor,
          elevation: 0,
          centerTitle: false,
          titleSpacing: -4,
          title: Row(
            children: [
              InkWell(
                onTap: _showAddressSelector,
                borderRadius: BorderRadius.circular(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Delivering to',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w300,
                        color: Colors.white70,
                      ),
                    ),
                    Row(
                      children: [
                        Text(
                          _selectedAddress,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        Icon(
                          Icons.keyboard_arrow_down,
                          size: 16,
                          color: Colors.white,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            Consumer<CartProvider>(
              builder: (_, cart, ch) => Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: Center(
                  child: Badge(
                    label: Text(cart.itemCount.toString()),
                    isLabelVisible: cart.itemCount > 0,
                    child: IconButton(
                      icon: Icon(
                        Icons.shopping_bag_outlined,
                        color: Colors.white,
                        size: 22,
                      ),
                      onPressed: () {
                        Navigator.pushNamed(context, '/cart');
                      },
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: IconButton(
                icon: Icon(Icons.person_outline, color: Colors.white),
                onPressed: () {
                  setState(() => _currentIndex = 3);
                },
              ),
            ),
          ],
          bottom: PreferredSize(
            preferredSize: Size.fromHeight(60),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: Align(
                alignment: Alignment.centerLeft,
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: double.infinity,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 36,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(color: Colors.black12, blurRadius: 4),
                            ],
                          ),
                          child: TextField(
                            controller: _searchController,
                            style: TextStyle(fontSize: 13),
                            decoration: InputDecoration(
                              hintText: 'Search for shops & restaurants',
                              hintStyle: TextStyle(
                                color: Colors.grey[400],
                                fontSize: 12,
                              ),
                              prefixIcon: Icon(
                                Icons.search,
                                color: AppTheme.primaryColor,
                                size: 18,
                              ),
                              border: InputBorder.none,
                              contentPadding:
                                  EdgeInsets.symmetric(vertical: 8),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 10),
                      Container(
                        height: 36,
                        width: 36,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(color: Colors.black12, blurRadius: 4),
                          ],
                        ),
                        child: IconButton(
                          padding: EdgeInsets.zero,
                          icon: Icon(
                            Icons.tune,
                            color: AppTheme.primaryColor,
                            size: 18,
                          ),
                          onPressed: () {
                            // Filter logic
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),

        // HERO SECTION
        SliverToBoxAdapter(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // HERO BANNER CAROUSEL
              SizedBox(height: 15),
              CarouselSlider(
                options: CarouselOptions(
                  height: 160.0,
                  autoPlay: true,
                  enlargeCenterPage: true,
                  viewportFraction: 0.88,
                  aspectRatio: 16 / 9,
                  initialPage: 0,
                ),
                items: [
                  'assets/images/burgerking.png',
                  'assets/images/mcdonalds.png',
                  'assets/images/kfc.png',
                  'assets/images/dominos.png',
                ].map((i) {
                  return Builder(
                    builder: (BuildContext context) {
                      return Container(
                        width: MediaQuery.of(context).size.width,
                        margin: EdgeInsets.symmetric(horizontal: 5.0),
                        decoration: BoxDecoration(
                          color: Colors.pink[50],
                          borderRadius: BorderRadius.circular(16),
                          image: DecorationImage(
                            image: AssetImage(i),
                            fit: BoxFit.cover,
                            onError: (_, __) {},
                          ),
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            gradient: LinearGradient(
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                              colors: [
                                Colors.black.withOpacity(0.7),
                                Colors.transparent,
                              ],
                            ),
                          ),
                          padding: EdgeInsets.all(15),
                          alignment: Alignment.bottomLeft,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'FLASH DEAL',
                                style: TextStyle(
                                  color: AppTheme.primaryColor,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w900,
                                  backgroundColor: Colors.white,
                                  letterSpacing: 1,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                '50% OFF TODAY!',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                }).toList(),
              ),

              SizedBox(height: 20),

              // CUISINES
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Cuisines',
                      style: AppTheme.headline1.copyWith(fontSize: 18),
                    ),
                    TextButton(
                      onPressed: () {},
                      child: Text(
                        'View all',
                        style: TextStyle(
                          color: AppTheme.primaryColor,
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 5),
              SizedBox(
                height: 100,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  children: [
                    _buildCuisineItem(
                      'Burgers',
                      'assets/images/burgerking.png',
                    ),
                    _buildCuisineItem('Pizza', 'assets/images/dominos.png'),
                    _buildCuisineItem('Healthy', 'assets/images/subway.png'),
                    _buildCuisineItem(
                      'Fast Food',
                      'assets/images/mcdonalds.png',
                    ),
                    _buildCuisineItem('Chicken', 'assets/images/kfc.png'),
                  ],
                ),
              ),
              SizedBox(height: 20),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  _selectedCategory == 'All'
                      ? 'All Restaurants'
                      : '$_selectedCategory',
                  style: AppTheme.headline1.copyWith(fontSize: 20),
                ),
              ),
              SizedBox(height: 10),
            ],
          ),
        ),

        // RESTAURANT LIST
        _filteredRestaurants.isEmpty
            ? SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(50.0),
                  child: Center(child: Text("No restaurants found")),
                ),
              )
            : SliverPadding(
                padding: EdgeInsets.fromLTRB(20, 8, 20, 32),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (BuildContext context, int index) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: _buildRestaurantCard(
                          _filteredRestaurants[index],
                        ),
                      );
                    },
                    childCount: _filteredRestaurants.length,
                  ),
                ),
              ),
      ],
    );
  }

  Widget _buildDesktopNavItem(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: TextButton(
        onPressed: () {},
        child: Text(
          title,
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  Widget _buildCuisineItem(String name, String imagePath) {
    bool isSelected = _selectedCategory == name;
    return GestureDetector(
      onTap: () {
        setState(() {
          if (_selectedCategory == name) {
            _selectedCategory = 'All';
          } else {
            _selectedCategory = name;
          }
          _filterRestaurants();
        });
      },
      child: Container(
        width: 80,
        margin: EdgeInsets.only(right: 15),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(3),
              decoration: BoxDecoration(
                color: isSelected ? AppTheme.primaryColor.withOpacity(0.1) : Colors.transparent,
                shape: BoxShape.circle,
                border: isSelected ? Border.all(color: AppTheme.primaryColor, width: 2) : Border.all(color: Colors.transparent, width: 2),
              ),
              child: Container(
                padding: EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.05),
                  shape: BoxShape.circle,
                ),
                child: CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.white,
                  backgroundImage: AssetImage(imagePath),
                  onBackgroundImageError: (_, __) {},
                  child: !isSelected ? Icon(Icons.fastfood, color: Colors.grey[300]) : null,
                ),
              ),
            ),
            SizedBox(height: 8),
            Text(
              name,
              style: TextStyle(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500, 
                fontSize: 12,
                color: isSelected ? AppTheme.primaryColor : Colors.black87,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRestaurantCard(Restaurant restaurant) {
    return Container(
      height: 140, // Fixed height for structured horizontal structure
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withOpacity(0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 15,
            spreadRadius: 0,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => RestaurantDetailScreen(restaurant: restaurant),
              ),
            );
          },
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Image Section
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16),
                      bottomLeft: Radius.circular(16),
                    ),
                    child: Image.asset(
                      restaurant.imagePath,
                      width: 130,
                      height: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: 130,
                          height: double.infinity,
                          color: Colors.grey[100],
                          child: Center(
                            child: Icon(
                              Icons.restaurant,
                              size: 40,
                              color: Colors.grey[300],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  // Delivery Time Tag
                  Positioned(
                    bottom: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 4,
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.access_time_rounded,
                            size: 12,
                            color: AppTheme.primaryColor,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            restaurant.deliveryTime,
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              // Details Section
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              restaurant.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Colors.black87,
                                letterSpacing: -0.3,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Consumer<FavoriteProvider>(
                            builder: (ctx, favoriteProvider, _) {
                              final isFavorite = favoriteProvider.isFavorite(restaurant.id);
                              return GestureDetector(
                                onTap: () {
                                  favoriteProvider.toggleFavorite(restaurant);
                                  
                                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        favoriteProvider.isFavorite(restaurant.id) 
                                          ? 'Added to favorites' 
                                          : 'Removed from favorites',
                                      ),
                                      duration: const Duration(seconds: 1),
                                      behavior: SnackBarBehavior.floating,
                                      backgroundColor: AppTheme.primaryColor,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                  );
                                },
                                child: Icon(
                                  isFavorite ? Icons.favorite : Icons.favorite_border,
                                  size: 22,
                                  color: isFavorite ? AppTheme.primaryColor : Colors.grey,
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${restaurant.category} • ${restaurant.priceRange}',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 13,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const Spacer(),
                      Row(
                        children: [
                          Icon(
                            Icons.star_rounded,
                            color: Colors.amber[500],
                            size: 18,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            restaurant.rating.toString(),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                          Text(
                            ' (500+)',
                            style: TextStyle(
                              color: Colors.grey[500],
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text(
                              'Free Delivery',
                              style: TextStyle(
                                color: AppTheme.primaryColor,
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.pink[50],
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text(
                              '20% OFF',
                              style: TextStyle(
                                color: AppTheme.primaryColor,
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
