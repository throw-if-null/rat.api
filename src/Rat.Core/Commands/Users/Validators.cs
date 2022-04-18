﻿using System;
using System.Collections.Generic;
using Rat.Commands.Users.CreateUser;
using Rat.Core.Properties;

namespace Rat.Commands.Users
{
	internal static class Validators
	{
		private static readonly KeyValuePair<string, string>[] Empty = Array.Empty<KeyValuePair<string, string>>();

		public static KeyValuePair<string, string>[] ValidateId(string authProviderUserId)
		{
			if (string.IsNullOrWhiteSpace(authProviderUserId))
			{
				return new KeyValuePair<string, string>[1]
				{
					new KeyValuePair<string, string>(CreateUserRequest.AuthProviderUserIdSignature, Resources.MustNotBeNullOrEmpty)
				};
			}

			return Empty;
		}
	}
}