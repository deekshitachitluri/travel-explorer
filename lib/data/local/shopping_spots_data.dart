import '../../models/shopping_spot.dart';

class ShoppingSpotsData {
  ShoppingSpotsData._();

  static List<ShoppingSpot> getSpotsForDestination(String destinationId) {
    return allSpots
        .where(
          (spot) =>
              spot.destinationId.toLowerCase() == destinationId.toLowerCase(),
        )
        .toList();
  }

  static const List<ShoppingSpot> allSpots = [
    // 1. JAIPUR
    ShoppingSpot(
      id: 'shop_jaipur_1',
      destinationId: 'jaipur',
      name: 'Johari Bazaar',
      locality: 'Pink City, Jaipur',
      knownFor: 'Authentic Kundan, Meenakari jewelry, silver treasures, and semi-precious gemstones',
      specialities: [
        'Kundan Jewelry',
        'Meenakari Enamel',
        'Silver Trinkets',
        'Gemstones',
      ],
      latitude: 26.9205,
      longitude: 75.8276,
      openingHours: '10:30 AM - 8:30 PM (Closed Sundays)',
      bestTimeToVisit: 'Late afternoons (4:00 PM - 7:00 PM)',
      tips: 'Always ask for hallmark certification when purchasing precious stones or jewelry.',
    ),
    ShoppingSpot(
      id: 'shop_jaipur_2',
      destinationId: 'jaipur',
      name: 'Bapu Bazaar',
      locality: 'MI Road / Chaura Rasta, Jaipur',
      knownFor: 'Camel leather Mojris, vibrant Leheriya sarees, and Block-printed Jaipuri quilts',
      specialities: [
        'Camel Leather Mojris',
        'Leheriya Sarees',
        'Jaipuri Razai',
        'Bandhani Fabric',
      ],
      latitude: 26.9180,
      longitude: 75.8210,
      openingHours: '11:00 AM - 8:30 PM (Daily)',
      bestTimeToVisit: 'Early evenings when the street lights turn on',
      tips: 'Gentle bargaining is traditional; explore the inner alleyways for independent master weavers.',
    ),

    // 2. DELHI
    ShoppingSpot(
      id: 'shop_delhi_1',
      destinationId: 'delhi',
      name: 'Chandni Chowk & Dariba Kalan',
      locality: 'Old Delhi',
      knownFor: 'Century-old silver and perfume shops, bridal lehengas, and exotic spice markets',
      specialities: [
        'Pure Silver Jewelry',
        'Attar Fragrances',
        'Zari Embroideries',
        'Khari Baoli Spices',
      ],
      latitude: 28.6562,
      longitude: 77.2307,
      openingHours: '11:00 AM - 8:00 PM (Closed Sundays)',
      bestTimeToVisit: 'Morning around 11:30 AM before the heavy evening rush',
      tips: 'Take a cycle rickshaw from Chandni Chowk metro station to navigate the heritage gullies.',
    ),
    ShoppingSpot(
      id: 'shop_delhi_2',
      destinationId: 'delhi',
      name: 'Dilli Haat INA',
      locality: 'Opposite INA Market, South Delhi',
      knownFor: 'Open-air village craft emporium with rotating state artisans and authentic regional foods',
      specialities: [
        'Tribal Bell Metal',
        'Madubani Art',
        'Pashmina Shawls',
        'Handloom Throws',
      ],
      latitude: 28.5732,
      longitude: 77.2078,
      openingHours: '10:30 AM - 10:00 PM (Daily)',
      bestTimeToVisit:
          'Sunset to enjoy evening handicraft strolls and regional food stalls',
      tips: 'Entry ticket is nominal (₹30); artisan stalls change every 15 days directly through national cooperatives.',
    ),

    // 3. SRINAGAR
    ShoppingSpot(
      id: 'shop_srinagar_1',
      destinationId: 'srinagar',
      name: 'Polo View High Street & Lal Chowk',
      locality: 'Polo View, Srinagar',
      knownFor: 'Pedestrian boulevard with GI-tagged Pashmina shawls, walnut wood carving, and saffron',
      specialities: [
        'Pure Cashmere Pashmina',
        'Carved Walnut Wood Boxes',
        'Kashmiri Saffron',
        'Paper Mâché Art',
      ],
      latitude: 34.0722,
      longitude: 74.8145,
      openingHours: '10:00 AM - 8:00 PM',
      bestTimeToVisit: 'Afternoon tea time',
      tips: 'Look for the official Kashmiri Craft GI registry QR-code labels on pure Pashmina shawls.',
    ),

    // 4. VARANASI
    ShoppingSpot(
      id: 'shop_varanasi_1',
      destinationId: 'varanasi',
      name: 'Thatheri Bazaar & Vishwanath Gali',
      locality: 'Near Kashi Vishwanath Temple, Varanasi',
      knownFor: 'Ancient metalcraft guild with hand-beaten brass puja items and heirloom Banarasi silks',
      specialities: [
        'Banarasi Katan Silk Sarees',
        'Handmade Brass Pooja Bells',
        'Rudraksha Beads',
        'Gulabi Meenakari',
      ],
      latitude: 25.3114,
      longitude: 83.0112,
      openingHours: '10:00 AM - 9:00 PM',
      bestTimeToVisit: 'After morning temple darshan',
      tips: 'Visit genuine weaver-owned lofts in Thatheri Bazaar to watch handloom jacquard weaving in real time.',
    ),

    // 5. KOCHI
    ShoppingSpot(
      id: 'shop_kochi_1',
      destinationId: 'kochi',
      name: 'Jew Town & Synagogue Lane',
      locality: 'Mattancherry, Fort Kochi',
      knownFor: 'Colonial antique warehouses, authentic Malabar spice houses, and Kerala brass Urulis',
      specialities: [
        'Antique Rosewood Furniture',
        'Traditional Kerala Urulis',
        'Tellicherry Black Pepper',
        'Vanilla Pods',
      ],
      latitude: 9.9578,
      longitude: 76.2597,
      openingHours: '10:00 AM - 7:30 PM (Closed Saturdays)',
      bestTimeToVisit: '3:00 PM - 6:00 PM',
      tips: 'The scent of cardamom and ginger fills the air; check antique dealers for provenance certificates.',
    ),

    // 6. MYSORE
    ShoppingSpot(
      id: 'shop_mysore_1',
      destinationId: 'mysore',
      name: 'Devaraja Market',
      locality: 'Sayyaji Rao Road, Mysore',
      knownFor: 'Historic Victorian market bursting with fresh jasmine garlands, sandalwood, and incense',
      specialities: [
        'Mysore Sandalwood Artifacts',
        'Natural Agarwood Agarbatti',
        'Mysore Silk Stoles',
        'Kumkum Powder',
      ],
      latitude: 12.3106,
      longitude: 76.6521,
      openingHours: '6:30 AM - 9:00 PM (Daily)',
      bestTimeToVisit: 'Morning for fresh flowers or late afternoon for perfumes and craft stalls',
      tips: 'For pure Mysore Silk, visit the Government Silk Weaving Factory on Mananthavady Road.',
    ),

    // 7. MADURAI
    ShoppingSpot(
      id: 'shop_madurai_1',
      destinationId: 'madurai',
      name: 'Puthu Mandapam Market',
      locality: 'Opposite Meenakshi Amman Temple East Tower, Madurai',
      knownFor: '17th-century pillared heritage arcade filled with tailor shops and bronze deity artisans',
      specialities: [
        'Hand-dyed Sungudi Cotton Sarees',
        'Bronze Sculptures',
        'Temple Jewelry',
        'Brass Oil Lamps',
      ],
      latitude: 9.9195,
      longitude: 78.1203,
      openingHours: '9:00 AM - 9:00 PM',
      bestTimeToVisit: 'Evening after temple visit',
      tips: 'Skilled tailors here can stitch customized traditional blouses within an hour.',
    ),

    // 8. AMRITSAR
    ShoppingSpot(
      id: 'shop_amritsar_1',
      destinationId: 'amritsar',
      name: 'Hall Bazaar & Katra Jaimal Singh',
      locality: 'Near Golden Temple, Amritsar',
      knownFor: 'Vibrant Punjabi folk craft, resplendent Phulkari threadwork, and artisanal juttis',
      specialities: [
        'Phulkari Dupattas & Shawls',
        'Handmade Amritsari Juttis',
        'Amritsari Papads & Wadiyan',
        'Steel Kadas',
      ],
      latitude: 31.6258,
      longitude: 74.8765,
      openingHours: '10:00 AM - 9:00 PM',
      bestTimeToVisit: 'Late afternoon',
      tips: 'Taste traditional Punjabi lassi at roadside stalls while shopping in Katra Jaimal Singh.',
    ),

    // 9. GOA
    ShoppingSpot(
      id: 'shop_goa_1',
      destinationId: 'goa',
      name: 'Anjuna Flea Market & Mapusa Market',
      locality: 'Anjuna Beach / Mapusa Town, Goa',
      knownFor: 'Bohemian beachfront flea markets, artisan leatherwork, feni, and spicy homemade Goan sausages',
      specialities: [
        'Handmade Brass Bohemian Jewelry',
        'Hand-painted Azulejo Tiles',
        'Chorizo (Goan Sausages)',
        'Cashew Nuts & Feni',
      ],
      latitude: 15.5786,
      longitude: 73.7412,
      openingHours: 'Wednesday 9:00 AM - 7:00 PM (Anjuna); Friday (Mapusa)',
      bestTimeToVisit: 'Wednesday afternoon towards sunset',
      tips: 'Bring cash; soak up the seaside live music and relaxed vintage market vibe.',
    ),

    // 10. MANALI
    ShoppingSpot(
      id: 'shop_manali_1',
      destinationId: 'manali',
      name: 'Old Manali Market & The Mall Road',
      locality: 'Old Manali Village & Mall Road, Manali',
      knownFor: 'Cobblestone boutique village alleys featuring hand-loomed Kullu shawls, wooden toys, and mountain herbs',
      specialities: [
        'Geometric Kullu Shawls',
        'Himachali Caps (Topis)',
        'Wild Pine Honey',
        'Hand-knitted Woolen Socks',
      ],
      latitude: 32.2530,
      longitude: 77.1780,
      openingHours: '10:00 AM - 8:30 PM',
      bestTimeToVisit: '4:00 PM - 7:30 PM',
      tips: 'The government Bhuttico weavers outlet offers authentic, fixed-price Kullu woolens.',
    ),

    // 11. LEH LADAKH
    ShoppingSpot(
      id: 'shop_ladakh_1',
      destinationId: 'ladakh',
      name: 'Leh Main Bazaar & Tibetan Market',
      locality: 'Main Bazaar, Leh Old Town',
      knownFor: 'Sun-drenched alpine market lined with Tibetan silver, turquoise prayer wheels, and yak wool blankets',
      specialities: [
        'Tibetan Singing Bowls',
        'Turquoise & Coral Amulets',
        'Yak Wool Weaves',
        'Ladakhi Apricot Oil',
      ],
      latitude: 34.1642,
      longitude: 77.5848,
      openingHours: '10:00 AM - 8:00 PM',
      bestTimeToVisit: '5:00 PM - 7:30 PM after day treks',
      tips: 'Leh Main Bazaar is now a clean pedestrian walkway; great place to sip sea buckthorn tea.',
    ),

    // 12. MUMBAI
    ShoppingSpot(
      id: 'shop_mumbai_1',
      destinationId: 'mumbai',
      name: 'Colaba Causeway & Crawford Market',
      locality: 'Colaba / Fort, South Mumbai',
      knownFor: 'Colonial arcade packed with vintage curiosities, antiquities, Kolhapuris, and street fashion',
      specialities: [
        'Brass Vintage Clocks',
        'Kolhapuri Chappals',
        'Bollywood Posters',
        'Indian Incense & Teas',
      ],
      latitude: 18.9220,
      longitude: 72.8315,
      openingHours: '10:30 AM - 9:30 PM',
      bestTimeToVisit: 'Late afternoon before dinner at Cafe Leopold',
      tips: 'Carry small cash denominations; enjoy browsing quirky vintage decor stalls along the footpath.',
    ),

    // 13. SHANTINIKETAN
    ShoppingSpot(
      id: 'shop_shantiniketan_1',
      destinationId: 'shantiniketan',
      name: 'Sonajhuri Shanibarer Haat (Saturday Market)',
      locality: 'Sonajhuri Forest, Shantiniketan',
      knownFor: 'Idyllic open-air tribal forest market with Dokra brass crafts, Baul singers, and Kantha stitching',
      specialities: [
        'Dokra Lost-wax Metal Art',
        'Kantha Embroidery Kurtas',
        'Terracotta Necklaces',
        'Shantiniketan Leather Bags',
      ],
      latitude: 23.6871,
      longitude: 87.6833,
      openingHours: 'Saturday 2:00 PM - 6:30 PM',
      bestTimeToVisit: '3:00 PM - 5:30 PM',
      tips: 'Held under the fragrant shade of Sonajhuri trees to the soulful tunes of wandering Baul minstrels.',
    ),

    // 14. PUDUCHERRY
    ShoppingSpot(
      id: 'shop_pondicherry_1',
      destinationId: 'pondicherry',
      name: 'Mission Street & Goubert Avenue Boutiques',
      locality: 'Heritage French Quarter, Puducherry',
      knownFor: 'Chic French-Tamil boutiques, Auroville handmade skincare, fragrant pottery, and linen garments',
      specialities: [
        'Auroville Hand-poured Candles',
        'Ceramic Tableware',
        'Organic Linen Wear',
        'Handmade Paper Books',
      ],
      latitude: 11.9340,
      longitude: 79.8322,
      openingHours: '10:00 AM - 8:30 PM',
      bestTimeToVisit: 'Late afternoon on bicycle',
      tips: 'Visit the Sri Aurobindo Handmade Paper Factory for eco-friendly stationery and journals.',
    ),

    // 15. UDAIPUR
    ShoppingSpot(
      id: 'shop_udaipur_1',
      destinationId: 'udaipur',
      name: 'Hathi Pol & Bada Bazaar',
      locality: 'Near Jagdish Temple, Udaipur',
      knownFor: 'Artisan quarters renowned for delicate Mewar miniature paintings, camel bone crafts, and Bandhej',
      specialities: [
        'Mewar Miniature Paintings',
        'Hand-bound Leather Travel Journals',
        'Pichwai Wall Hangings',
        'Bandhej Sarees',
      ],
      latitude: 24.5828,
      longitude: 73.6865,
      openingHours: '10:00 AM - 8:00 PM',
      bestTimeToVisit: 'Early evening',
      tips: 'Watch master painters in Hathi Pol paint intricate Pichwai motifs with single-hair squirrel brushes.',
    ),

    // 16. JODHPUR
    ShoppingSpot(
      id: 'shop_jodhpur_1',
      destinationId: 'jodhpur',
      name: 'Sardar Market & Clock Tower',
      locality: 'Ghanta Ghar, Jodhpur',
      knownFor: 'Lively spice and textile alleys under the British-era clock tower with views of Mehrangarh',
      specialities: [
        'Mathaniya Red Chillies',
        'Hand-dyed Turbans & Dupattas',
        'Teak Wood Antiques',
        'Mawa Kachori',
      ],
      latitude: 26.2952,
      longitude: 73.0232,
      openingHours: '10:00 AM - 9:00 PM',
      bestTimeToVisit: '5:00 PM - 8:00 PM',
      tips: 'Try the legendary Makhaniya Lassi at Shri Mishrilal Hotel right next to the market gate.',
    ),

    // 17. LUCKNOW
    ShoppingSpot(
      id: 'shop_lucknow_1',
      destinationId: 'lucknow',
      name: 'Hazratganj & Chowk Bazaar',
      locality: 'Hazratganj / Chowk, Lucknow',
      knownFor: 'Historic Nawabi shopping promenade celebrated for fine Chikankari needlecraft and regal Ittars',
      specialities: [
        'Hand-embroidered Chikankari Kurtas',
        'Natural Khus & Ruh Gulab Ittars',
        'Mukaish & Zardozi Stoles',
        'Awadhi Attar',
      ],
      latitude: 26.8524,
      longitude: 80.9458,
      openingHours: '11:00 AM - 9:00 PM (Closed Sundays in Chowk)',
      bestTimeToVisit:
          'Evening for Ganjing (leisurely strolls) along Victorian lampposts',
      tips: 'SEWA Lucknow (Self Employed Women\'s Association) is the best ethical store for genuine Chikankari.',
    ),

    // 18. HAMPI
    ShoppingSpot(
      id: 'shop_hampi_1',
      destinationId: 'hampi',
      name: 'Hampi Bazaar (Virupaksha Street)',
      locality: 'Virupaksha Temple Car Street, Hampi',
      knownFor: 'Rustic temple arcade offering stone sculptures, Lambani banjara embroidery, and travel trinkets',
      specialities: [
        'Hand-carved Stone Figurines',
        'Lambani Mirror-work Pouches',
        'Leather Travel Diaries',
        'Musical Instruments',
      ],
      latitude: 15.3350,
      longitude: 76.4600,
      openingHours: '8:30 AM - 8:00 PM',
      bestTimeToVisit: 'Early morning or late afternoon after exploring ruins',
      tips: 'Support local Lambani tribal women artisans directly near the Virupaksha complex.',
    ),

    // 19. SHILLONG
    ShoppingSpot(
      id: 'shop_shillong_1',
      destinationId: 'shillong',
      name: 'Police Bazar & Lewduh (Bara Bazar)',
      locality: 'Police Bazar, Central Shillong',
      knownFor: 'Energetic hill-station bazaar packed with Khasi bamboo crafts, tribal woven shawls, and wild honey',
      specialities: [
        'Khasi Cane & Bamboo Baskets',
        'Endi (Eri) Peace Silk Shawls',
        'Meghalaya Wild Orange Honey',
        'Handmade Wooden Toys',
      ],
      latitude: 25.5788,
      longitude: 91.8833,
      openingHours: '9:30 AM - 7:30 PM',
      bestTimeToVisit: 'Afternoon before hill twilight sets in',
      tips: 'Check Meghalaya State Handloom Emporium (Purbashree) on GS Road for certified organic silk.',
    ),

    // 20. DARJEELING
    ShoppingSpot(
      id: 'shop_darjeeling_1',
      destinationId: 'darjeeling',
      name: 'Chowrasta Mall & Nehru Road',
      locality: 'The Mall, Darjeeling',
      knownFor: 'Pedestrian promenade featuring legendary heritage tea boutiques, Tibetan woolens, and thangka paintings',
      specialities: [
        'Single-estate First Flush Darjeeling Tea',
        'Hand-knitted Himalayan Sweaters',
        'Tibetan Thangkas',
        'Silver Turquoise Charms',
      ],
      latitude: 27.0428,
      longitude: 88.2663,
      openingHours: '9:00 AM - 7:00 PM',
      bestTimeToVisit: 'Sunny afternoons overlooking Kanchenjunga',
      tips: 'Sample teas in heritage estates like Nathmulls Tea Cozy before choosing your favorite muscatel blend.',
    ),

    // 21. ALLEPPEY
    ShoppingSpot(
      id: 'shop_alleppey_1',
      destinationId: 'alleppey',
      name: 'Mullakkal Street & Canal Market',
      locality: 'Mullakkal, Alleppey',
      knownFor: 'Canalside street lined with natural golden coir mats, coconut shell crafts, and freshly crisped banana chips',
      specialities: [
        'Organic Coir Rugs & Mats',
        'Coconut Shell Bowls & Ladles',
        'Fresh Nendran Banana Chips in Pure Coconut Oil',
        'Kerala Green Cardamom',
      ],
      latitude: 9.4930,
      longitude: 76.3315,
      openingHours: '9:30 AM - 8:30 PM',
      bestTimeToVisit: 'Early evening after houseboat check-out',
      tips: 'Watch fresh banana chips being sliced directly into golden hot coconut oil at roadside sweet stalls.',
    ),

    // 22. MUNNAR
    ShoppingSpot(
      id: 'shop_munnar_1',
      destinationId: 'munnar',
      name: 'Munnar Town Market & Tea Sales Outlets',
      locality: 'Old Munnar, Munnar',
      knownFor: 'Fresh estate-grown high-elevation teas, artisanal chocolates, and cold-pressed eucalyptus oils',
      specialities: [
        'Kannan Devan Green Tea',
        'Handmade Herbal Eucalyptus Oil',
        'Spice-infused Dark Chocolates',
        'Fresh Cloves & Nutmeg',
      ],
      latitude: 10.0889,
      longitude: 77.0595,
      openingHours: '9:00 AM - 8:00 PM',
      bestTimeToVisit: '4:00 PM - 7:00 PM',
      tips: 'KDHP tea museum store offers fresh orthodox leaf straight from the surrounding misty slopes.',
    ),

    // 23. GANGTOK
    ShoppingSpot(
      id: 'shop_gangtok_1',
      destinationId: 'gangtok',
      name: 'MG Marg & Lal Bazaar',
      locality: 'MG Marg, Gangtok',
      knownFor: 'Spit-and-polish vehicle-free promenade with Sikkimese handloom carpets, Temi tea, and wooden Choktse tables',
      specialities: [
        'Temi Sikkim Organic Tea',
        'Foldable Wooden Choktse Tables',
        'Sikkimese Prayer Wheels',
        'Yak Cheese (Chhurpi)',
      ],
      latitude: 27.3314,
      longitude: 88.6138,
      openingHours: '10:00 AM - 8:00 PM (Closed Tuesdays)',
      bestTimeToVisit:
          'Evening to enjoy illuminated cobblestone benches and music',
      tips: 'Directorate of Handicrafts & Handloom on Zero Point sells authentic Lepcha and Bhutia weaves.',
    ),

    // 24. BHUBANESWAR
    ShoppingSpot(
      id: 'shop_bhubaneswar_1',
      destinationId: 'bhubaneswar',
      name: 'Ekamra Haat',
      locality: 'Unit 3, Madhusudan Nagar, Bhubaneswar',
      knownFor: 'Artisan craft village modeled like an ancient rural hamlet with Pipili applique and Pattachitra scrolls',
      specialities: [
        'Pipili Applique Lanterns & Umbrellas',
        'Raghurajpur Pattachitra Scroll Art',
        'Sambalpuri Ikat Silk',
        'Silver Tarakasi Filigree',
      ],
      latitude: 20.2922,
      longitude: 85.8340,
      openingHours: '10:00 AM - 9:00 PM (Daily)',
      bestTimeToVisit: 'Evening under warm terracotta fairy lights',
      tips: 'Watch master Pattachitra painters ink intricate tales of Jagannath on dried palm leaves.',
    ),

    // 25. HYDERABAD
    ShoppingSpot(
      id: 'shop_hyderabad_1',
      destinationId: 'hyderabad',
      name: 'Laad Bazaar (Choodi Bazaar)',
      locality: 'Near Charminar, Old City, Hyderabad',
      knownFor: 'Gleaming 400-year-old market famous for handmade lacquer bangles studded with glass crystals, pearls, and Bidriware',
      specialities: [
        'Handcrafted Lac Bangles',
        'Basra Natural Seed Pearls',
        'Bidriware Silver Inlay Boxes',
        'Zari Khada Dupattas',
      ],
      latitude: 17.3616,
      longitude: 78.4747,
      openingHours: '11:00 AM - 10:30 PM (Daily)',
      bestTimeToVisit:
          'Evening when thousands of twinkling bangles catch the city lights',
      tips: 'Bangle artisans will customize sizes on-the-spot; pairs wonderfully with hot Irani Chai and Osmania biscuits.',
    ),
  ];
}
