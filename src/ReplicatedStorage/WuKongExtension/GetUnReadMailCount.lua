local mailService
return function(user, container)
	if not mailService then
		mailService = require(game.ReplicatedStorage.Packages.MailService)
	end
	local unclaimedMails = mailService.GetUnclaimedMailList(user)
	if unclaimedMails then
		return #unclaimedMails
	end
	return 0
end