import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/currency_utils.dart';
import '../../core/utils/date_time_utils.dart';
import '../../data/models/bid_model.dart';

/// Bid History Widget
class BidHistoryWidget extends StatelessWidget {
  final List<BidModel> bids;
  final String? currentUserId;
  final int maxVisible;

  const BidHistoryWidget({
    super.key,
    required this.bids,
    this.currentUserId,
    this.maxVisible = 5,
  });

  @override
  Widget build(BuildContext context) {
    if (bids.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Center(
          child: Column(
            children: [
              Icon(
                Icons.gavel_outlined,
                size: 48,
                color: AppColors.textHint,
              ),
              SizedBox(height: 12),
              Text(
                'لا توجد مزايدات بعد',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 16,
                ),
              ),
              SizedBox(height: 4),
              Text(
                'كن أول من يزايد!',
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      );
    }

    final visibleBids = bids.take(maxVisible).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'سجل المزايدات',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (bids.length > maxVisible)
              TextButton(
                onPressed: () => _showAllBids(context),
                child: Text('عرض الكل (${bids.length})'),
              ),
          ],
        ),
        const SizedBox(height: 12),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: visibleBids.length,
          separatorBuilder: (_, __) => const Divider(height: 1),
          itemBuilder: (context, index) {
            final bid = visibleBids[index];
            final isHighestBid = index == 0;
            final isCurrentUser = bid.bidderId == currentUserId;

            return _BidTile(
              bid: bid,
              isHighestBid: isHighestBid,
              isCurrentUser: isCurrentUser,
            );
          },
        ),
      ],
    );
  }

  void _showAllBids(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        expand: false,
        builder: (context, scrollController) => Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: AppColors.divider)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'جميع المزايدات (${bids.length})',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.separated(
                controller: scrollController,
                itemCount: bids.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final bid = bids[index];
                  return _BidTile(
                    bid: bid,
                    isHighestBid: index == 0,
                    isCurrentUser: bid.bidderId == currentUserId,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BidTile extends StatelessWidget {
  final BidModel bid;
  final bool isHighestBid;
  final bool isCurrentUser;

  const _BidTile({
    required this.bid,
    required this.isHighestBid,
    required this.isCurrentUser,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
      color: isCurrentUser
          ? (isHighestBid
              ? AppColors.success.withValues(alpha: 0.1)
              : AppColors.error.withValues(alpha: 0.1))
          : null,
      child: Row(
        children: [
          // Rank indicator
          if (isHighestBid)
            Container(
              width: 28,
              height: 28,
              decoration: const BoxDecoration(
                color: AppColors.success,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.emoji_events,
                color: Colors.white,
                size: 16,
              ),
            )
          else
            const SizedBox(width: 28),
          const SizedBox(width: 12),

          // Bidder info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      isCurrentUser ? 'أنت' : bid.bidderName,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: isCurrentUser ? AppColors.primary : null,
                      ),
                    ),
                    if (bid.isAutoBid) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.secondary.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'تلقائي',
                          style: TextStyle(
                            fontSize: 10,
                            color: AppColors.secondary,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  DateTimeUtils.getRelativeTimeArabic(bid.createdAt),
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),

          // Bid amount
          Text(
            CurrencyUtils.formatIQD(bid.amount),
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isHighestBid ? AppColors.success : AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
