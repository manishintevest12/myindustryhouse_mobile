/// Platform roles. The backend response decides the role; the mobile app
/// only routes on it. ADMIN is recognized solely to be BLOCKED on mobile.
enum AppRole { buyer, seller, admin }

extension AppRoleX on AppRole {
  String get label => switch (this) {
        AppRole.buyer => 'Buyer',
        AppRole.seller => 'Seller',
        AppRole.admin => 'Admin',
      };
}
