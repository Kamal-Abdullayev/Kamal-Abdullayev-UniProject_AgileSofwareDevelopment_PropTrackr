defmodule WhiteBreadConfig do
      use WhiteBread.SuiteConfiguration

      suite name:          "Not interested",
          context:       NotInterestedContext,
          feature_paths: ["features/not_interested.feature"]

      suite name:          "Search page",
          context:       SearchContext,
          feature_paths: ["features/search.feature"]

      suite name:          "Home page",
          context:       HomePageContext,
          feature_paths: ["features/home_page.feature"]

      suite name:          "App loading",
            context:       AppLoadingContext,
            feature_paths: ["features/app_loading.feature"]

      suite name:          "Auth",
            context:       AuthContext,
            feature_paths: ["features/auth.feature"]

      suite name:          "Favorites",
            context:       FavoriteContext,
            feature_paths: ["features/favorite.feature"]

      suite name:          "Manage Advertisements",
            context:       AdvertisementContext,
            feature_paths: ["features/advertisement.feature"]

      suite name:         "Past search",
          context:      PastSearchContext,
          feature_paths: ["features/past_search.feature"]

      suite name:          "Block user",
            context:       BlockContext,
            feature_paths: ["features/block_user.feature"]

      suite name:          "Change password",
            context:       ChangePasswordContext,
            feature_paths: ["features/change_password.feature"]

      suite name:          "Edit user profile",
            context:       EditProfileContext,
            feature_paths: ["features/edit_profile.feature"]

      suite name:          "Delete user",
            context:       DeleteUserContext,
            feature_paths: ["features/delete_user.feature"]

    end
